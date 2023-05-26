# Grafana-loki-sample

## Summary

<!-- TOC -->

- [Grafana-loki-sample](#grafana-loki-sample)
    - [Summary](#summary)
    - [架構](#%E6%9E%B6%E6%A7%8B)
        - [write:](#write)
            - [ecs -> fluent-bit -> s3](#ecs---fluent-bit---s3)
        - [read:](#read)
            - [s3 -> local folder -> promtail -> loki -> grafana](#s3---local-folder---promtail---loki---grafana)
    - [選用 編輯配置-初始化倒入log](#%E9%81%B8%E7%94%A8-%E7%B7%A8%E8%BC%AF%E9%85%8D%E7%BD%AE-%E5%88%9D%E5%A7%8B%E5%8C%96%E5%80%92%E5%85%A5log)
    - [執行啟動](#%E5%9F%B7%E8%A1%8C%E5%95%9F%E5%8B%95)
    - [倒入log](#%E5%80%92%E5%85%A5log)
        - [把未經過gzip的log檔案放到.minio-init/data/ungzip下](#%E6%8A%8A%E6%9C%AA%E7%B6%93%E9%81%8Egzip%E7%9A%84log%E6%AA%94%E6%A1%88%E6%94%BE%E5%88%B0minio-initdataungzip%E4%B8%8B)
        - [把經過gzip的log檔案放到.minio-init/data/gzip下](#%E6%8A%8A%E7%B6%93%E9%81%8Egzip%E7%9A%84log%E6%AA%94%E6%A1%88%E6%94%BE%E5%88%B0minio-initdatagzip%E4%B8%8B)
    - [Grafana](#grafana)
        - [登入 Grafana](#%E7%99%BB%E5%85%A5-grafana)
        - [連上 Loki 加入 data source](#%E9%80%A3%E4%B8%8A-loki-%E5%8A%A0%E5%85%A5-data-source)
        - [檢索 LOG](#%E6%AA%A2%E7%B4%A2-log)
    - [搜尋log範例](#%E6%90%9C%E5%B0%8Blog%E7%AF%84%E4%BE%8B)
    - [清除資料](#%E6%B8%85%E9%99%A4%E8%B3%87%E6%96%99)

<!-- /TOC -->


---
## 架構

### write:
#### ecs -> fluent-bit -> s3

### read:
#### s3 -> local folder -> promtail -> loki -> grafana


---

## (選用) 編輯配置-初始化倒入log


編輯取得s3上log所需要的帳號資訊及路徑
```
vim .env

AWS_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXX
AWS_SECRET_KEY=XXXXXXXXXXXXXXXXXXXXX
AWS_BUCKET=XXXXXXX
```


調整初始化腳本(可以用 MinIO Client 取得 s3 的 log)
```
vim insertion.sh
```

解開 `minio-init` 區塊的註解
```
vim docker-compose.yaml
```

重新執行從 s3 取得 log
```
docker-compose up minio-init
```


---

## 執行啟動
```
docker-compose up -d
```

---

## 倒入log
### 把未經過gzip的log檔案放到`.minio-init/data/ungzip`下
### 把經過gzip的log檔案放到`.minio-init/data/gzip`下




---

## Grafana
### 登入 Grafana

登入 http://localhost:3000

> Username: admin <br>
> Password: admin <br>


---

### 連上 Loki 加入 data source
登入Grafana後, 左邊菜單選擇Administration->Data Sources->Add data source <br>
選擇Loki <br>
然後在URL輸入 http://loki:3100/ <br>
按下Save & Test <br>
出現`Data source connected and labels found.`表示Grafana成功連上Loki <br>

---

### 檢索 LOG
到Grafana左邊選單的`Explore`這裡 <br>
左上角選擇`Loki` <br>
來到`Label browser`會看到job有出現剛剛倒入的`log-ungzip`或`log-gzip`label, 選擇要看的label, 然後選擇`show logs` <br>

---

## 搜尋log範例

```

### 找關鍵字
{job="log"}|= "2023-05-18T06:19"

### 解析 json
{job="log"} | json

### 解析 json 後找欄位指定值
{job="log"}| json | date="2023-05-18T06:19:48.016256Z"

### 找關鍵字後解析 json
{job="log"}|= "Request finished"|= "GET" |= "resTime"| json


```

---

## 清除資料

```
rm -rf .minio-init
```




---

登入 minIO
http://localhost:9000



> Username: loki <br>
> Password: supersecret <br>







ref:

Getting started
https://grafana.com/docs/loki/latest/getting-started/

Log Agent - Fluent Bit Output + Loki + Grafana
https://ithelp.ithome.com.tw/articles/10281493

Loki 生產環境集羣方案
https://www.readfog.com/a/1642645824064294912



https://www.readfog.com/a/1672132575247831040







