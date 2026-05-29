# 前端 Demo 設定指南

## 方式一：Hardhat 本地節點（離線，最穩定）

> 需要 Node.js。適合在教室沒有網路時使用。

### 1. 啟動本地區塊鏈節點
```bash
npm install -g hardhat
npx hardhat node
```
啟動後會看到 20 個測試帳號，每個有 10000 ETH，記下 **Private Key**。

### 2. MetaMask 新增本地網路
- 網路名稱：`Hardhat Local`
- RPC URL：`http://127.0.0.1:8545`
- 鏈 ID：`31337`
- 幣種符號：`ETH`

匯入 Hardhat 的測試帳號私鑰（至少匯入 5 個，分別對應 5 種角色）。

### 3. Remix 連接本地節點
1. Remix → Deploy & Run Transactions
2. Environment 選 **`External Http Provider`**
3. 填入 `http://127.0.0.1:8545`
4. 部署合約 → 複製合約地址

### 4. 開啟前端
直接用瀏覽器開啟 `index.html`，貼上合約地址即可。

---

## 方式二：Sepolia 測試網（需要網路）

> 適合有網路的環境，不需要安裝 Node.js。

### 1. 取得測試 ETH
前往 Sepolia Faucet 領取測試幣：
- https://sepoliafaucet.com
- https://faucet.quicknode.com/ethereum/sepolia

### 2. MetaMask 切換到 Sepolia
設定 → 進階 → 顯示測試網路 → 選擇 Sepolia

### 3. Remix 使用 Injected Provider
Remix → Environment 選 **`Injected Provider - MetaMask`**（確認 MetaMask 在 Sepolia）

部署合約 → 複製合約地址

### 4. 開啟前端
直接用瀏覽器開啟 `index.html`，貼上合約地址即可。

---

## Demo 當天流程

```
1. 連接 MetaMask（Owner 帳號）
2. 貼上合約地址 → 點「載入合約」
3. 角色管理 → 指派 4 個帳號角色
4. 切換帳號到 Producer → 批次登記
5. 切換帳號到各角色 → 依序新增記錄
6. 溯源查詢 → 展示完整履歷（此頁最適合截圖）
7. 切換到 Regulator → 產品召回
8. 再次溯源查詢 → 展示召回後仍可查歷史（區塊鏈不可竄改）
```
