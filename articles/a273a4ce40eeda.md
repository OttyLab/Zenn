---
title: "ヒートマップレイヤーの勘所"
emoji: "☁️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Mapbox", "MapboxGLJS", "GIS", "JavaScript", "Heatmap"]
published: false
publication_name: "mapbox_japan"
---

# はじめに

[Mapbox Newsletter WEEKLY TIPSの解説 -「ヒートマップレイヤーの作成」](https://zenn.dev/mapbox_japan/articles/994ad131240411)ではサンプルを用いてヒートマップレイヤーの使い方を確認しました。この記事ではヒートマップが内部的にどのような処理をしているのかについて見ていきます。また、「手持ちのデータで試してみたけど全体的に`0`や`1`の色になってしまってうまくいかない」という場合にも参考にもなるかと思います。

[こちらのブログ](https://blog.mapbox.com/introducing-heatmaps-in-mapbox-gl-js-71355ada9e6c)で詳細が解説されているので合わせてご参照ください。


# カーネル密度推定

ヒートマップは密度を色で表現するレイヤーでした。ここで言う密度とは「ポイントデータがどれぐらい密に存在するか」ということです。ただし、ポイントデータそのままでは離散値なのでポイント自体は密度`1`, ポイントとポイントの間の地点が密度`0`のような状態になってしまいます。ヒートマップレイヤーとしては、ポイント間もそれぞれのポイントからの影響に応じて密度を決めていい感じの色を出力したいです。そこで利用されるのが[カーネル密度推定](https://ja.wikipedia.org/wiki/%E3%82%AB%E3%83%BC%E3%83%8D%E3%83%AB%E5%AF%86%E5%BA%A6%E6%8E%A8%E5%AE%9A)です。

カーネル密度推定はポイントデータの地点を中心とする正規分布を仮定します。例えば以下の図のように、あるポイントが正規分布の中心に来ます。そしてその周辺になだらかな山状に値が分布します。ポイント地点での値を`1`とすると、ポイントの近くであれば`0.9`だったり、遠くであれば`0.1`だったりします。これによりポイントの影響を周囲に反映させることができますね！

![Normal 01](/images/articles/a273a4ce40eeda/normal_01.png)

複数のポイントが存在するときは正規分布が重ね合わされます。以下の図ではポイント1による正規分布の山が青線、ポイント2による正規分布の山が赤線、それらの重ね合わせがオレンジ色の線です。重ね合わせると値が`1`を超えることがありますが、ヒートマップでは`1`以上の値は`1`にクリップされます。

![Normal 02](/images/articles/a273a4ce40eeda/normal_02.png)


# 実際の値を確認

さて、`heatmap-weight`の値が`1`のときにポイントデータの地点の密度の値も`1`になるのでしょうか？実は`heatmap-weight`が`1`、 `heatmap-intensity`が`1`のとき、密度は`0.3989422804014327`になります。中途半端な値に見えますが、これは標準正規分布の山の頂上の値です。

![Normal 03](/images/articles/a273a4ce40eeda/normal_03.png)

以下のようなヒートマップレイヤーを作って挙動を確かめてみました。値が`0.3989422804014327`に近づくと色が青色（`rgb(0,0,255)`）になります。少しでも超えると（`0.3989422804014327`）緑色（`rgb(0,255,0)`）になります。そこから`0.9999999999999999`に近づくにつれ赤色（`rgb(255,0,0)`）になり、`1`で白色（rgb(255,255,255)）となります。

```JavaScript
map.addLayer({
  id: "layer",
  type: "heatmap",
  source: "source",
  paint: {
    "heatmap-weight": 1,
    "heatmap-intensity": 1,
    "heatmap-color": [
      "interpolate",
      ["linear"],
      ["heatmap-density"],
      0.39,
      "rgba(0,0,0,0.1)",
      0.3989422804014327,
      "rgb(0,0,255)",
      0.3989422804014328,
      "rgb(0,255,0)",
      0.9999999999999999,
      "rgb(255,0,0)",
      1,
      "rgb(255,255,255)"
    ]
  }
});
```

具体的に挙動を見てみましょう。

少し見にくいですが、東京駅の東西に1個ずつ、神田駅に1個の合計3個のポイントが表示されてます。各々離れているので`0.3989422804014327`近辺の青色で表示されています。
![Heatmap 01](/images/articles/a273a4ce40eeda/heat_01.png)

次に少しズームアウトします。すると東京駅東西の2個のポイントが接近し、緑色になります。2個の正規分布が合わさっている様子がわかりますね。
![Heatmap 02](/images/articles/a273a4ce40eeda/heat_02.png)

更にズームアウトすると東京駅は赤色に近づいていきます。さらに、神田駅のポイントも緑色になっているので東京駅の2個のポイントの影響を受けていることがわかります。
![Heatmap 03](/images/articles/a273a4ce40eeda/heat_03.png)

もっとズームアウトすると3個のポイントが重なり合い、中心が白色になります。3個の正規分布が重ね合わされて`1`になることがわかります。`0.3989422804014327 * 3 = 1.1968268412042981`なので、`1`にクリップされているということですね。
![Heatmap 04](/images/articles/a273a4ce40eeda/heat_04.png)

以下にサンプルを置いているので、ぜひズームアウトして動きを確認してください。
@[codepen](https://codepen.io/OttyLab/pen/yLQERmM)


# `heatmap-intensity`や`heatmap-radius`を変更すると？

`heatmap-intensity`は密度の値に直接乗算されます。つまり`heatmap-intensity`を`2`に変更すると、密度の値も2倍になります。以下は`heatmap-intensity`を`2`にしたときの結果です。中心の値が`0.3989422804014327`より大きくなっているのがわかります。
![intensity](/images/articles/a273a4ce40eeda/intensity.png)

`heatmap-radius`は正規分布の裾の長さを調整します。数学的には正規分布は無限に広がりますが、そうするとある地点の値はすべてのポイントからの正規分布の値を合算する必要があり大変です。そこでデフォルトでは[`30`ピクセル](https://docs.mapbox.com/mapbox-gl-js/style-spec/layers/#heatmap:~:text=in%20pixels.-,Defaults%20to%2030,-.%20Supports%20feature)まで計算します。以下は`heatmap-radius`を`60`にしたときの結果です。青色の領域が少し広がっているので影響範囲が広がっているのがわかります。
![radius](/images/articles/a273a4ce40eeda/radius.png)


# まとめ

`heatmap-weight`が`1`、 `heatmap-intensity`が`1`のとき値はだいたい`0.4`、つまりポイントが3個重なると`1`を超えるということを覚えておくと、各種パラメータを変更するときに検討しやすいのではないかと思います。


# おまけ

ヒートマップレイヤーは正規分布の重ね合わせをシェーダーで処理しています。以下のコードが該当箇所ですのでご参照ください。`0.3989422804014327`というマジックナンバーも[ここ](https://github.com/mapbox/mapbox-gl-js/blob/v2.15.0/src/shaders/heatmap.fragment.glsl#L8C20-L8C38)で定義されています。

https://github.com/mapbox/mapbox-gl-js/blob/v2.15.0/src/shaders/heatmap.vertex.glsl
https://github.com/mapbox/mapbox-gl-js/blob/v2.15.0/src/shaders/heatmap.fragment.glsl