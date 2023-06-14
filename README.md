# Grafana-loki-sample

## Summary

<!-- TOC -->

- [Grafana-loki-sample](#grafana-loki-sample)
    - [Summary](#summary)
    - [架構](#%E6%9E%B6%E6%A7%8B)
        - [read:](#read)
            - [s3 -> local folder -> promtail -> loki -> grafana](#s3---local-folder---promtail---loki---grafana)
    - [log 格式範例](#log-%E6%A0%BC%E5%BC%8F%E7%AF%84%E4%BE%8B)
    - [（選用）編輯配置-初始化倒入log](#%E9%81%B8%E7%94%A8%E7%B7%A8%E8%BC%AF%E9%85%8D%E7%BD%AE-%E5%88%9D%E5%A7%8B%E5%8C%96%E5%80%92%E5%85%A5log)
        - [使用 aws-cli 下載 log](#%E4%BD%BF%E7%94%A8-aws-cli-%E4%B8%8B%E8%BC%89-log)
        - [使用 MinIO Client 下載 log](#%E4%BD%BF%E7%94%A8-minio-client-%E4%B8%8B%E8%BC%89-log)
    - [（選用）編輯 promtail 採集規則](#%E9%81%B8%E7%94%A8%E7%B7%A8%E8%BC%AF-promtail-%E6%8E%A1%E9%9B%86%E8%A6%8F%E5%89%87)
    - [執行啟動](#%E5%9F%B7%E8%A1%8C%E5%95%9F%E5%8B%95)
    - [手動倒入log](#%E6%89%8B%E5%8B%95%E5%80%92%E5%85%A5log)
        - [把未經過gzip的log檔案放到data/ungzip下](#%E6%8A%8A%E6%9C%AA%E7%B6%93%E9%81%8Egzip%E7%9A%84log%E6%AA%94%E6%A1%88%E6%94%BE%E5%88%B0dataungzip%E4%B8%8B)
        - [把經過gzip的log檔案放到data/gzip下](#%E6%8A%8A%E7%B6%93%E9%81%8Egzip%E7%9A%84log%E6%AA%94%E6%A1%88%E6%94%BE%E5%88%B0datagzip%E4%B8%8B)
    - [Grafana](#grafana)
        - [登入 Grafana](#%E7%99%BB%E5%85%A5-grafana)
        - [連上 Loki 加入 data source](#%E9%80%A3%E4%B8%8A-loki-%E5%8A%A0%E5%85%A5-data-source)
        - [檢索 LOG](#%E6%AA%A2%E7%B4%A2-log)
    - [搜尋log範例](#%E6%90%9C%E5%B0%8Blog%E7%AF%84%E4%BE%8B)
    - [清除資料](#%E6%B8%85%E9%99%A4%E8%B3%87%E6%96%99)
    - [log 統計範例](#log-%E7%B5%B1%E8%A8%88%E7%AF%84%E4%BE%8B)

<!-- /TOC -->


---
## 架構
return [Summary](#summary)

<!--
### write:
#### ecs -> fluent-bit -> s3
-->
### read:
#### s3 -> local folder -> promtail -> loki -> grafana

---
## log 格式範例
return [Summary](#summary)

```
{
  "date": "2023-02-30T06:31:52.115504Z",
  "level": 20,
  "requestId": "9166b7e4-7d95-452c-8c71-d618c6f48552",
  "msg": "Request finished",
  "requestMethod": "GET",
  "requestURL": "/api/v2/aaa",
  "version": "1.1",
  "status": "200",
  "resSize": "99byte",
  "resTime": "44.028ms",
  "simplifiedRes": "ok",
  "container_name": "backend-container",
  "source": "stdout",
  "container_id": "6486b4d2e496423683e6d7787b8bf8c2-3641692242"
}
```

---

## （選用）編輯配置-初始化倒入log
return [Summary](#summary)

編輯取得s3上log所需要的帳號資訊及路徑

vim .env
```
AWS_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXX
AWS_SECRET_KEY=XXXXXXXXXXXXXXXXXXXXX
AWS_BUCKET=XXXXXXX
```

### 使用 aws-cli 下載 log
return [Summary](#summary)

調整初始化腳本(可以用 aws-cli 取得 s3 的 log)
```
vim downdoadS3Log.sh
```

解開 `aws-cli` 區塊的註解
```
vim docker-compose.yaml
```

重新執行從 s3 取得 log
```
docker-compose up -d aws-cli
```

---

### 使用 MinIO Client 下載 log
return [Summary](#summary)

ref: https://min.io/docs/minio/linux/reference/minio-mc.html

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
docker-compose up -d minio-init
```

---

## （選用）編輯 promtail 採集規則
return [Summary](#summary)

```
vim promtail-local-config.yaml
```

可以自動解壓縮 gzip 的 log
```
...
- job_name: log-gzip
  decompression:
    enabled: true
    format: gz
...
```


可以用 date 欄位取代上傳的時間
```
...
  pipeline_stages:
    - docker:
    - json:
        expressions:
          date:
    - timestamp:
        source: date
        format: RFC3339
...
```

---

## 執行啟動
return [Summary](#summary)

```
docker-compose up -d
```

---

## 手動倒入log
return [Summary](#summary)

### 把未經過gzip的log檔案放到`data/ungzip`下
### 把經過gzip的log檔案放到`data/gzip`下




---

## Grafana
### 登入 Grafana
return [Summary](#summary)

登入 http://localhost:3000

> Username: admin <br>
> Password: admin <br>


---

### 連上 Loki 加入 data source
return [Summary](#summary)

登入Grafana後, 左邊菜單選擇Administration->Data Sources->Add data source <br>
選擇Loki <br>
然後在URL輸入 http://loki:3100/ <br>
按下Save & Test <br>
出現`Data source connected and labels found.`表示Grafana成功連上Loki <br>

---

### 檢索 LOG
return [Summary](#summary)

到Grafana左邊選單的`Explore`這裡 <br>
左上角選擇`Loki` <br>
來到`Label browser`會看到job有出現剛剛倒入的`log-ungzip`或`log-gzip`label, 選擇要看的label, 然後選擇`show logs` <br>

---

## 搜尋log範例
return [Summary](#summary)

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
return [Summary](#summary)

```
rm -rf data
```

---

## log 統計範例
return [Summary](#summary)

> ref: https://grafana.com/docs/loki/latest/logql/metric_queries/ <br>
> 有效的時間單元有: ms,s,m,h,d,w,y

> ref: https://grafana.com/docs/loki/latest/logql/log_queries/
> 有效的 Bytes 單元有: “b”, “kib”, “kb”, “mib”, “mb”, “gib”, “gb”, “tib”, “tb”, “pib”, “pb”, “eib”, “eb”.

列舉出{job="log-gzip"})過去5分鐘的log數量, 並且以requestURL作為維度來進行統計, 秀出各requestURL的數量
```

### 找 resTime 超過特定 ms
topk(20,sum(count_over_time({job="log-gzip"}|= "Request finished"|json|resTime>5000ms| __error__=""[10d])) by (requestURL))

### 找 resSize 超過特定 byte
topk(20,sum(count_over_time({job="log-gzip"}|= "Request finished"|json|resSize>50B| __error__=""[10d])) by (requestURL))


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







