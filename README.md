# ベンチマーク集

ほぼ同一の設計・処理をするコードを各言語で書き，それらの実行時間を比較することで，言語の実行速度をベンチマークしています．

## ベンチマーク一覧

| 実行時間(s) | オセロ |
| --- | ----: |
| Golang | 0.83 |
| Haxe→JS | 1.2 |
| Haxe→C++ | 2.8 |
| OCaml | 3.3 |
| Haskell | 4.5 |
| TS→JS | 5.7 |
| PHP | 38 |


## プログラム一覧
### オセロα-β探索
オセロの初期局面から10手の深さに渡ってα-β探索を行います．

## 言語一覧
偏見による紹介．宗教的理由により動的言語を直接書くことが出来ません．

### Golang
低級言語の中で書くとしたらこれだろと思っている言語．型システムがイケてます．

### TypeScript→JavaScript
JS書くならTSを書きたいですね．JSのゆるさをいい感じにやってくれます．オブジェクトに対する部分型も文化にあってます．

### Haxe→C++
最適化の方法がよくわかりません．配列にpushしていっているのが遅いのかもしれないです．って生成されるコード見てみたらDynamicとか色々書いてあってすごく汚かった．要改善か．

### Haxe→JavaScript
なぜかHaxe→C++より速かったりして謎．

### Haskell
純粋関数型言語．これだけ書いて暮らせるなら幸せな人生が送れることでしょう．しかし速度面では，チューニングしないといとも簡単に激遅コードが出来上がってしまいます．

### OCaml
mutableも可能な関数型言語．盤面探索では盤面をmutableにすれば，コピーすることなくimperativeな言語のような速度が達成できています．

### PHP
PHPで書いてます．おえっ
