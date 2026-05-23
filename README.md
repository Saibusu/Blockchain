# 區塊鏈技術於食品供應鏈之創新應用

> 「鏈接未來：區塊鏈創新應用」專題研究計畫

## 專案簡介

本專題研究區塊鏈技術如何解決食品供應鏈中長期存在的資訊不透明、產地造假與食安事件應對遲緩等問題，並以以太坊智能合約實作一套食品溯源概念驗證系統（Proof of Concept）。

## 核心問題

- 資訊不透明與資料孤島（Data Silos）
- 假冒偽劣與產地造假（全球每年損失超過 400 億美元）
- 食安事件追查費時（數天至數週）
- 冷鏈管理缺乏客觀驗證機制
- 人工作業效率低落

## 解決方案

利用區塊鏈以下核心特性：

| 特性 | 對食品供應鏈的意義 |
|------|------------------|
| 去中心化 | 無單一控制方，各方地位對等 |
| 不可竄改 | 杜絕產地造假、記錄竄改 |
| 透明可追溯 | 消費者可即時查詢食品來源 |
| 智能合約 | 自動付款、超溫警報、認證管理 |

> **成效參考：** 沃爾瑪（Walmart）導入區塊鏈溯源後，芒果產地追溯時間從 **6.5 天縮短至 2.2 秒**。

## 技術實作（PoC）

### 開發環境

| 項目 | 內容 |
|------|------|
| 區塊鏈平台 | 以太坊（Ethereum） |
| 開發工具 | Remix IDE |
| 程式語言 | Solidity ^0.8.0 |
| 測試環境 | JavaScript VM（Remix 內建） |

### 專案結構

```
├── contracts/
│   └── FoodTraceability.sol    # 智能合約主程式
└── docs/
    └── report.md               # 完整研究報告
```

### 合約架構

```
FoodTraceability Contract
├── 資料結構
│   ├── FoodBatch        — 食品批次基本資料
│   └── TraceRecord      — 單筆供應鏈追蹤記錄
├── 角色管理
│   ├── Producer（1）    — 生產者
│   ├── Processor（2）   — 加工商
│   ├── Logistics（3）   — 物流商
│   ├── Retailer（4）    — 零售商
│   └── Regulator（5）   — 監管機關
└── 核心函式
    ├── registerBatch()      — 登記食品批次（Producer）
    ├── addTraceRecord()     — 新增供應鏈環節記錄
    ├── deactivateBatch()    — 停用批次 / 產品召回（Regulator）
    ├── getBatchInfo()       — 查詢批次基本資訊
    ├── getBatchHistory()    — 查詢完整批次履歷
    └── assignRole()         — 管理員指派角色
```

### 快速開始

1. 開啟 [Remix IDE](https://remix.ethereum.org/)
2. 匯入 `contracts/FoodTraceability.sol`
3. 選擇編譯器版本 `0.8.x` 並編譯
4. 部署至 **JavaScript VM**（測試環境）
5. 依序執行：
   - `assignRole()` — 指派各帳號角色
   - `registerBatch()` — 生產者登記批次
   - `addTraceRecord()` — 各環節上鏈記錄
   - `getBatchHistory()` — 查詢完整履歷

### 操作範例

```
批次登記：
  batchId:        "BATCH-2025-001"
  productName:    "有機高麗菜"
  origin:         "宜蘭縣員山鄉"
  productionDate: 1748131200

各環節記錄：
  加工廠  | 台北市大同區 | 清洗分級包裝 | 4.0°C
  物流商  | 國道一號冷藏車 | 低溫冷藏運輸 | 4.2°C
  零售商  | 新北市板橋全聯 | 商品上架   | 6.0°C
```

> 溫度超過 8.0°C 時，合約自動觸發 `TemperatureAlert` 事件。

## 研究報告

完整研究內容請參閱 [docs/report.md](docs/report.md)，涵蓋：
- 食品供應鏈業務情境分析
- 現狀問題與區塊鏈解決方案
- 機遇與挑戰（含 Oracle Problem 討論）
- 技術實作細節與操作說明
- 未來展望（IoT 整合、聯盟鏈架構）

## 技術參考

- Nakamoto, S. (2008). *Bitcoin: A Peer-to-Peer Electronic Cash System*
- Buterin, V. (2014). *Ethereum: A Next-Generation Smart Contract and Decentralized Application Platform*
- Walmart & IBM (2018). *Food Trust: Blockchain for Food Safety*
- [Solidity Documentation](https://docs.soliditylang.org/)
