# 區塊鏈技術於食品供應鏈之創新應用

> 「鏈接未來：區塊鏈創新應用」專題研究計畫 — 終極生產等級驗證版（PoC Verified）

## 專案簡介

本專題研究區塊鏈技術如何解決食品供應鏈中長期存在的資訊不透明、產地造假與食安事件應對遲緩等問題，並以以太坊智慧合約實作一套食品溯源概念驗證系統（Proof of Concept）。本系統已通過底層儲存指標優化，具備強健的防禦性動態風控機制。

## 核心問題

- **資訊不透明與資料孤島（Data Silos）**：供應鏈各節點數據私有，出事時難以串聯。
- **假冒偽劣與產地造假**：缺乏去中心化的信任根基，標籤極易被偽造（全球每年損失超過 400 億美元）。
- **食安事件追查費時**：傳統中心化系統追查耗時數天至數週，錯失黃金召回時機。
- **冷鏈管理缺乏客觀驗證**：物聯網數據易在私有資料庫中被廠商事後竄改或隱匿。
- **人工作業防禦力低落**：缺乏底層合約修飾子（Modifiers）硬性限制越權操作。

## 解決方案

利用區塊鏈以下核心特性：

| 特性 | 對食品供應鏈的意義 | 本系統具體實作 |
|------|------------------|----------------|
| **去中心化** | 無單一控制方，各方地位對等，打破資料孤島 | 多節點角色共同維護同一鏈上帳本 |
| **不可竄改** | 杜絕產地造假、物流數據事後塗改與時間倒填 | 區塊打包自動生成客觀 Unix 時間戳記 |
| **透明可追溯** | 消費者與稽查單位可一鍵查詢食品全生命週期 | 鏈上動態元組陣列（Tuple Array）完美還原軌跡 |
| **智慧合約** | 降低信任成本、超溫主動警報、自動化防禦 | 內建 `TemperatureAlert` 與 `batchExists` 攔截 |

> **成效參考：** 沃爾瑪（Walmart）導入區塊鏈溯源後，芒果產地追溯時間從 **6.5 天縮短至 2.2 秒**。

---

## 技術實作與架構優化

### 開發與編譯環境

為避免以太坊最新硬分叉操作碼與虛擬機執行環境產生衝突，本專案嚴格限制編譯與部署環境對齊：

| 項目 | 設定規格 / 修正方案 |
|------|------|
| **區塊鏈平台** | 以太坊（Ethereum） |
| **開發工具** | VS Code / Remix IDE |
| **程式語言** | Solidity `^0.8.0` |
| **EVM Version** | **強行鎖定 `shanghai`**（避免預設 `osaka` 新操作碼動態陣列記憶體衝突） |
| **測試環境** | Remix VM (Shanghai) / 本地本地端節點 |

### 重大 Bug 修復與重構紀錄 (Engineering Fixes)
- **儲存區直寫法 (Storage Pointer) 重構**：原版合約在 `mapping(string => Struct[])` 的動態陣列中使用 `memory` 暫存結構體進行 `.push()`，會引發 EVM 內存分配錯位並噴出 `invalid opcode` 致命崩潰。本版本將其完全重構為**儲存區直寫法**，先執行空 `.push()` 配置 Storage 空間，再透過 `lastIndex` 顯式指針寫入，徹底根治記憶體越界問題。
- **模擬時鐘落差相容**：移除了會因網頁前端傳輸延遲而誤判廠商「預知未來」的 require 機制，改以區塊客觀時間為準，大幅提升模擬環境下的部署穩定性。

### 專案結構


```

├── codes/
│   └── FoodTraceability.sol    # 智慧合約主程式（已完成內存重構與優化）
└── docs/
└── report.md               # 完整研究報告（含五階段測試解碼數據）

```

### 合約架構


```

FoodTraceability Contract
├── 資料結構
│   ├── FoodBatch        — 食品批次基本資料（含生產者地址、生產地、生產日期、有效狀態）
│   └── TraceRecord      — 單筆供應鏈追蹤記錄（包含 Handler、Role、Location、Action、Temperature、Timestamp）
├── 角色管理 (RBAC 基於角色的權限控管)
│   ├── None（0）        — 未註冊之路人（預設最高防禦，無寫入權限）
│   ├── Producer（1）    — 生產者（唯一可啟動商品生命週期、註冊批次者）
│   ├── Processor（2）   — 加工商
│   ├── Logistics（3）   — 物流商（內建冷鏈超溫監控）
│   ├── Retailer（4）    — 零售商
│   └── Regulator（5）   — 監管機關（唯一擁有最終審判權與一鍵下架召回權者）
└── 核心函式
├── assignRole()         — 【限 Owner】管理員核發權限（避免廠商自我授權）
├── registerBatch()      — 【限 Producer】登記食品批次
├── addTraceRecord()     — 【限 1~5 角色】新增供應鏈環節記錄（超溫動態觸發警報）
├── deactivateBatch()    — 【限 Regulator】一鍵停用批次 / 產品召回
├── batches()            — 查詢批次基本狀態（包含觀測 isActive 是否為有效）
└── getBatchHistory()    — 查詢不可篡改之完整動態履歷大陣列

```

---

## 快速開始與連續技演練指南

為展示「先留鐵證、後處分」的工業級動態風控流程，請依據以下標準步驟進行 PoC 驗證：

### 1. 權限初始化 (RBAC)
使用部署合約之最高管理員帳號（Account 1），呼叫 `assignRole`，依序將你的目標測試地址綁定對應角色。為求測試流暢，亦可將角色編號 `1` (Producer) 與 `3` (Logistics) 同時指派給同一個測試帳號。

### 2. 五階段生命週期標準測試參數
依序執行下列功能，將數據打包寫入區塊鏈：

* **【階段 1：生產者採收】** 呼叫 `registerBatch`
  - `_batchId`: `"BATCH-2026-FINAL"`
  - `_productName`: `"有機高麗菜"`
  - `_origin`: `"宜蘭縣三星鄉"`
  - `_productionDate`: `1653436800` (客觀過去時間戳記)
* **【階段 2：加工商進場】** 呼叫 `addTraceRecord`
  - `_location`: `"礁溪截切包裝廠"`
  - `_action`: `"低溫清洗、冷藏包裝完成"`
  - `_temperature`: `40` (代表 4.0°C，安全冷鏈)
* **【階段 3：冷鏈物流爆發異常】** 呼叫 `addTraceRecord`
  - `_location`: `"國道一號冷藏車"`
  - `_action`: `"冷鏈轉轉運中（發現車廂失溫異常）"`
  - `_temperature`: **`95`** (🔥故意輸入 9.5°C！智慧合約底層 `_temperature > 80` 條件成立，**鏈上當場秒噴 `TemperatureAlert` 告警事件！**)
* **【階段 4：通路端拒收把關】** 呼叫 `addTraceRecord`
  - `_location`: `"全聯福利中心 中山晴光店"`
  - `_action`: `"門市檢測到鏈上 TemperatureAlert，予以拒收並移至隔離區"`
  - `_temperature`: `70` (7.0°C)
  - *(註：此時合約並未盲目終止，批次 `isActive` 仍為 `true`，確保全聯門市能合法寫入這筆品管鐵證，責任歸屬一目了然)*
* **【階段 5：主管機關降臨處分】** 呼叫 `addTraceRecord` 後呼叫召回
  - `_location`: `"臺北市衛生局檢驗科"`
  - `_action`: `"判定該批次嚴重失溫銷毀，啟動重大食安召回處分"`
  - `_temperature`: `250`
  - **【終審判決】**：隨後由衛生局地址呼叫 **`deactivateBatch("BATCH-2026-FINAL")`**。合約將 `isActive` 變更為 `false`，全面封鎖該批次後續所有操作，全案結案。

### 3. 成果收割
點擊藍色唯讀函式 **`getBatchHistory("BATCH-2026-FINAL")`**，系統將回傳完美的 Tuple Array，將此不可篡改之鏈上五階段追責數據（包含每個環節的發起地址、精準溫度與遞增時間戳記）截圖，即可作為期末報告之核心成果。

---

## 未來優化方向 (Future Outlook)

1. **硬體端 Oracle（預言機）整合**：計畫引入 **Chainlink Oracle** 技術，將實體物流冷藏車之 NodeMCU 溫度感應器數據「無人為介入、自動直接上鏈」，防範前端惡意登錄。
2. **Layer 2 擴展方案與隱私計算**：導入 Arbitrum 或 Optimism 聯盟鏈架構以大幅降低頻繁更新物流狀態所需之 Gas Fee 手續費，並結合零知識證明（ZKP）保護廠商產量與價格隱私。

## 技術參考

- Nakamoto, S. (2008). *Bitcoin: A Peer-to-Peer Electronic Cash System*
- Buterin, V. (2014). *Ethereum: A Next-Generation Smart Contract and Decentralized Application Platform*
- Walmart & IBM (2018). *Food Trust: Blockchain for Food Safety*
- [Solidity Documentation](https://docs.soliditylang.org/)

```
