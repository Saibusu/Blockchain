# Demo 操作指南
## 區塊鏈食品供應鏈溯源系統（FoodTraceability PoC）

> **報告 Demo 專用** — 依本文件步驟操作，約 10 分鐘完成完整展示流程

---

## 事前準備

1. 開啟瀏覽器，前往 [https://remix.ethereum.org](https://remix.ethereum.org)
2. 在左側 File Explorer 點選「+」新增檔案 `FoodTraceability.sol`
3. 貼上 `codes/FoodTraceability.sol` 的完整程式碼

---

## 步驟一：編譯合約

1. 點選左側 **Solidity Compiler**（盾牌圖示）
2. Compiler 版本選擇 **`0.8.x`**（任一 0.8 版本皆可）
3. 點選藍色按鈕 **「Compile FoodTraceability.sol」**
4. 看到左側出現綠色勾勾 ✅ = 編譯成功

---

## 步驟二：部署合約

1. 點選左側 **Deploy & Run Transactions**（火箭圖示）
2. Environment 選擇 **「Remix VM (Cancun)」**（或任一 JavaScript VM）
3. Contract 下拉選單確認選到 **`FoodTraceability`**
4. 點選橘色按鈕 **「Deploy」**
5. 下方 Deployed Contracts 出現合約地址 = 部署成功

> **提示：** 部署後，Remix 會自動用帳號 `Account[0]` 部署，此帳號即為合約 **owner（監管機關 Regulator）**

---

## 步驟三：記錄帳號地址（關鍵準備）

點選 Account 下拉選單，依序複製以下帳號地址備用：

| 編號 | 帳號 | 角色 |
|------|------|------|
| Account[0] | `0x5B3...` | Owner / Regulator（監管機關） |
| Account[1] | `0xAb8...` | Producer（農場生產者） |
| Account[2] | `0x4B0...` | Processor（加工廠） |
| Account[3] | `0x787...` | Logistics（物流商） |
| Account[4] | `0xdd8...` | Retailer（零售商） |

> 每台電腦的地址不同，請以 Remix 實際顯示為準

---

## 步驟四：指派角色

**確認目前帳號為 Account[0]（Owner）**

展開 Deployed Contracts → `FoodTraceability` → 找到 **`assignRole`** 函式

依序執行以下 4 次指派：

### 4-1 指派生產者
```
_addr:  [Account[1] 的地址]
_role:  1
```
點選 **transact** → Logs 出現 `RoleAssigned` event ✅

### 4-2 指派加工商
```
_addr:  [Account[2] 的地址]
_role:  2
```
點選 **transact** ✅

### 4-3 指派物流商
```
_addr:  [Account[3] 的地址]
_role:  3
```
點選 **transact** ✅

### 4-4 指派零售商
```
_addr:  [Account[4] 的地址]
_role:  4
```
點選 **transact** ✅

---

## 步驟五：登記食品批次（生產者）

**切換帳號至 Account[1]（Producer）**

找到 **`registerBatch`** 函式，輸入以下參數：

```
_batchId:        BATCH-2025-001
_productName:    有機高麗菜
_origin:         宜蘭縣員山鄉
_productionDate: 1748131200
```

點選 **transact** → Logs 出現 `BatchRegistered` event ✅

> 合約自動建立第一筆產地記錄，無需另外呼叫

---

## 步驟六：各環節上鏈記錄

### 6-1 加工廠記錄（切換至 Account[2]）

找到 **`addTraceRecord`** 函式：

```
_batchId:     BATCH-2025-001
_location:    台北市大同區加工廠
_action:      清洗分級包裝完成，通過品管檢驗
_temperature: 40
```

點選 **transact** → Logs 出現 `RecordAdded` event ✅

---

### 6-2 物流商記錄（切換至 Account[3]）

```
_batchId:     BATCH-2025-001
_location:    國道一號冷藏車廂
_action:      低溫冷藏運輸中，溫濕度正常
_temperature: 42
```

點選 **transact** ✅

---

### 6-3 零售商記錄（切換至 Account[4]）

```
_batchId:     BATCH-2025-001
_location:    新北市板橋全聯超市
_action:      商品上架完成，保存期限標示正確
_temperature: 60
```

點選 **transact** ✅

---

## 步驟七：消費者查詢履歷（Demo 亮點）

**任意帳號皆可查詢（切換回 Account[0]）**

找到 **`getBatchHistory`** 函式（藍色按鈕）：

```
_batchId: BATCH-2025-001
```

點選 **call** → 下方展開顯示 4 筆記錄：

| # | 操作者角色 | 地點 | 操作 | 溫度 |
|---|-----------|------|------|------|
| 0 | Producer(1) | 宜蘭縣員山鄉 | Product harvested... | 25.0°C |
| 1 | Processor(2) | 台北市大同區加工廠 | 清洗分級包裝完成 | 4.0°C |
| 2 | Logistics(3) | 國道一號冷藏車廂 | 低溫冷藏運輸中 | 4.2°C |
| 3 | Retailer(4) | 新北市板橋全聯超市 | 商品上架完成 | 6.0°C |

> **報告說明重點：** 這份記錄寫入區塊鏈後不可竄改，任何人掃描 QR Code 即可取得相同資料。

---

## 步驟八：超溫警報展示（Demo 加分場景）

**切換至 Account[3]（物流商）**，模擬冷鏈斷鏈：

```
_batchId:     BATCH-2025-001
_location:    桃園休息站（冷藏車故障）
_action:      冷藏設備故障，緊急通報
_temperature: 150
```

點選 **transact** → Logs 同時出現兩個 events：
- `RecordAdded` ✅
- **`TemperatureAlert`** 🚨（temperature: 150 = 15.0°C，超過 8.0°C 閾值）

> **報告說明重點：** 智能合約自動偵測超溫並廣播警報事件，無需人工介入，IoT 整合後可即時通知相關方。

---

## 步驟九：產品召回展示（Demo 加分場景）

**切換至 Account[0]（Regulator 監管機關）**

找到 **`deactivateBatch`** 函式：

```
_batchId: BATCH-2025-001
```

點選 **transact** → 批次狀態設為停用 ✅

**驗證：召回後仍可查詢歷史**（這是修復後的關鍵行為）

再次呼叫 **`getBatchHistory`**：

```
_batchId: BATCH-2025-001
```

> **報告說明重點：** 即使批次被監管機關召回停用，完整的供應鏈歷史記錄仍永久保存在區塊鏈上，消費者與監管機關仍可追查問題根源。這是區塊鏈「不可竄改」特性的核心展示。

---

## 完整 Demo 流程摘要

```
部署合約
  ↓
指派角色（Owner → 各帳號）
  ↓
registerBatch（農場生產者登記批次）
  ↓
addTraceRecord × 3（加工廠 → 物流商 → 零售商）
  ↓
getBatchHistory（消費者查詢完整履歷）★ 主要展示
  ↓
addTraceRecord，temperature: 150（超溫警報觸發）★ 加分展示
  ↓
deactivateBatch（監管機關召回）
  ↓
getBatchHistory（召回後仍可查）★ 區塊鏈不可竄改特性
```

---

## 常見問題排查

| 問題 | 原因 | 解法 |
|------|------|------|
| `Unauthorized: incorrect role` | 目前帳號角色不符 | 確認右上角 Account 是否切換正確 |
| `Batch ID already registered` | 該 batchId 已存在 | 改用不同 batchId（如 BATCH-2025-002） |
| `Batch not found` | batchId 拼寫錯誤 | 確認大小寫完全一致 |
| 函式呼叫後無反應 | 讀取函式不產生 transaction | 藍色按鈕 = 讀取（免費），橘色按鈕 = 寫入（消耗 Gas） |
| 部署後看不到合約 | 需展開 Deployed Contracts | 點選左下角 `>` 展開 |
