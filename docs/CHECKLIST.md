# 前端操作清單 — FoodChain Demo

> 依典型 Demo 順序排列。每項操作標注**前提角色**與**預期結果**。

---

## 準備階段

| # | 操作 | 前提 | 預期結果 |
|---|------|------|---------|
| P-1 | 啟動本地節點或連接測試網 | — | RPC 可用 |
| P-2 | 在 Remix 部署 FoodTraceability.sol | MetaMask 連接同一網路 | 取得合約地址 |
| P-3 | 開啟 `frontend/index.html` | 瀏覽器已安裝 MetaMask | 頁面正常載入 |
| P-4 | 點選「連接 MetaMask」 | MetaMask 已解鎖 | 顯示帳號地址與角色 |
| P-5 | 貼上合約地址 → 點「載入合約」 | P-4 完成 | 顯示「✅ 合約載入成功」 |

---

## 角色管理（Owner 帳號）

| # | 操作 | Tab | 前提角色 | 預期結果 |
|---|------|-----|---------|---------|
| A-1 | 指派 Account[1] → Producer (1) | 角色管理 | Owner | RoleAssigned event 出現於交易記錄 |
| A-2 | 指派 Account[2] → Processor (2) | 角色管理 | Owner | RoleAssigned event |
| A-3 | 指派 Account[3] → Logistics (3) | 角色管理 | Owner | RoleAssigned event |
| A-4 | 指派 Account[4] → Retailer (4) | 角色管理 | Owner | RoleAssigned event |
| A-5 | 查詢各帳號角色確認正確 | 角色管理 | 任意 | 顯示對應角色徽章 |

---

## 批次登記（Producer 帳號）

| # | 操作 | Tab | 前提角色 | 預期結果 |
|---|------|-----|---------|---------|
| B-1 | 切換 MetaMask 到 Account[1] | — | — | 頁面角色顯示更新為 Producer |
| B-2 | 填入批次編號、產品名稱、產地、生產日期 | 批次登記 | Producer | — |
| B-3 | 點「登記批次上鏈」 | 批次登記 | Producer | BatchRegistered event；頂部出現批次徽章 |
| B-4 | 確認其他 Tab 的批次編號已自動填入 | 各 Tab | — | 無需手動輸入 |

---

## 供應鏈記錄（各角色帳號）

| # | 操作 | Tab | 前提角色 | 溫度說明 | 預期結果 |
|---|------|-----|---------|---------|---------|
| C-1 | Account[2] 新增加工廠記錄，溫度 4.0°C | 新增記錄 | Processor | `40`（正常）| RecordAdded event；無警報 |
| C-2 | Account[3] 新增物流記錄，溫度 9.5°C | 新增記錄 | Logistics | `95`（超溫）| RecordAdded + **TemperatureAlert** event |
| C-3 | Account[4] 新增零售記錄，溫度 7.0°C | 新增記錄 | Retailer | `70`（正常）| RecordAdded event；無警報 |

---

## 溯源查詢（任意帳號）

| # | 操作 | Tab | 預期結果 |
|---|------|-----|---------|
| D-1 | 輸入批次編號 → 點「查詢」 | 溯源查詢 | 顯示批次基本資訊卡片 |
| D-2 | 查看供應鏈履歷時間軸 | 溯源查詢 | 每個環節的角色、地點、溫度、時間戳記 |
| D-3 | 確認超溫記錄以紅色標示 | 溯源查詢 | 物流階段溫度徽章為紅色 |

---

## 產品召回（Regulator 帳號）

| # | 操作 | Tab | 前提角色 | 預期結果 |
|---|------|-----|---------|---------|
| E-1 | 切換 MetaMask 到 Account[0]（Owner/Regulator） | — | — | 角色顯示更新 |
| E-2 | 輸入批次編號 → 點「執行產品召回」 | 產品召回 | Regulator | 確認 popup 出現 |
| E-3 | 確認召回 popup | 產品召回 | Regulator | 交易成功；isActive = false |

---

## 召回後驗證（展示區塊鏈不可竄改特性）

| # | 操作 | Tab | 預期結果 |
|---|------|-----|---------|
| F-1 | 再次查詢同一批次 | 溯源查詢 | 批次資訊卡顯示「⛔ 已召回」紅色狀態 |
| F-2 | 確認完整履歷仍可查閱 | 溯源查詢 | 時間軸所有記錄依然完整顯示（追責永久保存）|
| F-3 | 嘗試新增記錄（應失敗） | 新增記錄 | 交易 revert，顯示「Batch does not exist or is inactive」|

---

## 操作時序圖

```
Owner       Producer    Processor   Logistics   Retailer    Regulator
  │             │            │           │           │           │
  ├─ A-1~A-4 ──┤            │           │           │           │
  │  指派角色   │            │           │           │           │
  │             ├─ B-2,B-3 ─┤           │           │           │
  │             │  登記批次  │           │           │           │
  │             │            ├─ C-1 ────┤           │           │
  │             │            │  加工廠   │           │           │
  │             │            │           ├─ C-2 ────┤           │
  │             │            │           │  物流     │           │
  │             │            │           │ ⚠️超溫警報│           │
  │             │            │           │           ├─ C-3 ────┤
  │             │            │           │           │  零售     │
  │             │            │           │           │           ├─ E-2,E-3
  │             │            │           │           │           │  召回
  ├─────────────────── D-1,D-2,F-1,F-2 ─────────────────────────┤
                              溯源查詢（任意帳號皆可）
```
