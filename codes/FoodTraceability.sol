// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title FoodTraceability
 * @notice 食品供應鏈溯源智能合約（Proof of Concept）
 * @dev 區塊鏈創新應用專題 — 食品供應鏈主題
 * 使用平台：Remix IDE  語言：Solidity ^0.8.0
 */
contract FoodTraceability {

    // =========================================================
    //  角色定義
    // =========================================================
    enum Role { None, Producer, Processor, Logistics, Retailer, Regulator }

    // =========================================================
    //  資料結構
    // =========================================================

    /// @dev 單筆供應鏈追蹤記錄
    struct TraceRecord {
        address handler;       // 操作者帳號
        uint256 role;          // 已優化：改用整數（1=Producer, 2=Processor...）避免底層 Enum 衝突
        string  location;      // 操作地點
        string  action;        // 操作描述
        int256  temperature;   // 溫度（放大10倍，例：90 = 9.0°C）
        uint256 timestamp;     // 區塊時間戳記
    }

    /// @dev 食品批次基本資料
    struct FoodBatch {
        string  batchId;        // 批次編號
        string  productName;    // 產品名稱
        string  origin;         // 產地
        uint256 productionDate; // 生產日期（Unix timestamp）
        address producer;       // 生育者地址
        bool    isActive;       // 批次是否有效
    }

    // =========================================================
    //  狀態變數
    // =========================================================
    mapping(string => FoodBatch)     public batches;
    mapping(string => TraceRecord[]) public traceHistory;
    mapping(address => Role)         public roles;
    address public owner;

    // =========================================================
    //  事件
    // =========================================================
    event BatchRegistered(string indexed batchId, string productName, address producer);
    event RecordAdded(string indexed batchId, address handler, string action, uint256 timestamp);
    event TemperatureAlert(string indexed batchId, int256 temperature, address reporter);
    event RoleAssigned(address indexed account, Role role);

    // =========================================================
    //  修飾子
    // =========================================================

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    modifier onlyRole(Role _role) {
        require(roles[msg.sender] == _role, "Unauthorized: incorrect role");
        _;
    }

    modifier batchExists(string memory _batchId) {
        require(batches[_batchId].isActive, "Batch does not exist or is inactive");
        _;
    }

    modifier onlyRegisteredParticipant() {
        require(roles[msg.sender] != Role.None, "Caller is not a registered participant");
        _;
    }

    // =========================================================
    //  建構子
    // =========================================================
    constructor() {
        owner = msg.sender;
        roles[msg.sender] = Role.Regulator; // 讓合約部署者預設為監管機關
    }

    // =========================================================
    //  角色管理
    // =========================================================

    /**
     * @notice 指派角色給指定地址（僅限合約擁有者）
     * @param _addr  目標地址
     * @param _role  指派角色（1=Producer, 2=Processor, 3=Logistics, 4=Retailer, 5=Regulator）
     */
    function assignRole(address _addr, Role _role) external onlyOwner {
        roles[_addr] = _role;
        emit RoleAssigned(_addr, _role);
    }

    /**
     * @notice 查詢指定地址的角色
     * @param _addr  查詢地址
     * @return 角色編號
     */
    function getRole(address _addr) external view returns (Role) {
        return roles[_addr];
    }

    // =========================================================
    //  核心功能
    // =========================================================

    /**
     * @notice 登記新食品批次（僅限 Producer 角色）
     * @param _batchId        批次編號（需唯一）
     * @param _productName    產品名稱
     * @param _origin         產地描述
     * @param _productionDate 生產日期（Unix timestamp）
     */
    function registerBatch(
        string memory _batchId,
        string memory _productName,
        string memory _origin,
        uint256 _productionDate
    ) external onlyRole(Role.Producer) {
        require(bytes(_batchId).length > 0, "Batch ID cannot be empty");
        require(bytes(batches[_batchId].batchId).length == 0, "Batch ID already registered");
        require(_productionDate <= block.timestamp, "Production date cannot be in the future");

        batches[_batchId] = FoodBatch({
            batchId:        _batchId,
            productName:    _productName,
            origin:         _origin,
            productionDate: _productionDate,
            producer:       msg.sender,
            isActive:       true
        });

        // 🔥 【已修復】直接在 Storage 儲存空間初始化並寫入，徹底解決內存分配的 invalid opcode Bug
        traceHistory[_batchId].push(); 
        uint256 lastIndex = traceHistory[_batchId].length - 1;
        
        traceHistory[_batchId][lastIndex].handler = msg.sender;
        traceHistory[_batchId][lastIndex].role = uint256(Role.Producer);
        traceHistory[_batchId][lastIndex].location = _origin;
        traceHistory[_batchId][lastIndex].action = "Product harvested and registered on blockchain";
        traceHistory[_batchId][lastIndex].temperature = 250; // 預設 25.0°C
        traceHistory[_batchId][lastIndex].timestamp = block.timestamp;

        emit BatchRegistered(_batchId, _productName, msg.sender);
        emit RecordAdded(_batchId, msg.sender, "Product harvested and registered on blockchain", block.timestamp);
    }

    /**
     * @notice 新增供應鏈環節記錄（所有已登記參與者均可呼叫）
     * @param _batchId     批次編號
     * @param _location    操作地點
     * @param _action      操作描述
     * @param _temperature 當前溫度（×10，例：90 = 9.0°C）
     */
    function addTraceRecord(
        string memory _batchId,
        string memory _location,
        string memory _action,
        int256        _temperature
    ) external batchExists(_batchId) onlyRegisteredParticipant {

        // 🔥 【已修復】對齊直寫邏輯，物流商動態追加紀錄絕不卡死
        traceHistory[_batchId].push();
        uint256 lastIndex = traceHistory[_batchId].length - 1;
        
        traceHistory[_batchId][lastIndex].handler = msg.sender;
        traceHistory[_batchId][lastIndex].role = uint256(roles[msg.sender]);
        traceHistory[_batchId][lastIndex].location = _location;
        traceHistory[_batchId][lastIndex].action = _action;
        traceHistory[_batchId][lastIndex].temperature = _temperature;
        traceHistory[_batchId][lastIndex].timestamp = block.timestamp;

        // 冷鏈超溫警告：超過 8.0°C（即 _temperature > 80）自動觸發
        if (_temperature > 80) {
            emit TemperatureAlert(_batchId, _temperature, msg.sender);
        }

        emit RecordAdded(_batchId, msg.sender, _action, block.timestamp);
    }

    /**
     * @notice 停用批次（例：召回或下架，僅限 Regulator）
     * @param _batchId  批次編號
     */
    function deactivateBatch(string memory _batchId)
        external
        onlyRole(Role.Regulator)
        batchExists(_batchId)
    {
        batches[_batchId].isActive = false;
    }

    // =========================================================
    //  查詢函式（view）
    // =========================================================

    /**
     * @notice 查詢批次基本資訊
     * @param _batchId  批次編號
     * @return FoodBatch struct
     */
    function getBatchInfo(string memory _batchId)
        external view
        returns (FoodBatch memory)
    {
        require(bytes(batches[_batchId].batchId).length > 0, "Batch not found");
        return batches[_batchId];
    }

    /**
     * @notice 查詢批次完整供應鏈履歷（批次召回後仍可查詢，供追責用）
     * @param _batchId  批次編號
     * @return TraceRecord 陣列（依時間先後排列）
     */
    function getBatchHistory(string memory _batchId)
        external view
        returns (TraceRecord[] memory)
    {
        require(bytes(batches[_batchId].batchId).length > 0, "Batch not found");
        return traceHistory[_batchId];
    }

    /**
     * @notice 查詢批次追蹤記錄總筆數（批次召回後仍可查詢）
     * @param _batchId  批次編號
     * @return 記錄筆數
     */
    function getTraceCount(string memory _batchId)
        external view
        returns (uint256)
    {
        require(bytes(batches[_batchId].batchId).length > 0, "Batch not found");
        return traceHistory[_batchId].length;
    }
}