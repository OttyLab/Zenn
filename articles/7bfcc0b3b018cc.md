---
title: "Mapbox Newsletter WEEKLY TIPSの解説 -「陰影処理を追加」"
emoji: "🏔️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Mapbox", "MapboxGLJS", "GIS", "JavaScript"]
published: true
publication_name: "mapbox_japan"
---

# はじめに

この記事は、先日配信されたMapbox NewsletterのWEEKLY TIPSで紹介されていた「陰影処理を追加」についての解説です。このサンプルでは[`hillshade`レイヤー](https://docs.mapbox.com/style-spec/reference/layers#hillshade)の使い方について例示しています。また、Newsletterの購読は[こちら](https://www.mapbox.jp/blog?#:~:text=%E3%83%8B%E3%83%A5%E3%83%BC%E3%82%B9%E3%83%AC%E3%82%BF%E3%83%BC%E3%82%92%E8%B3%BC%E8%AA%AD)からお申し込みいただけます。

以下が本サンプルのデモです。

@[codepen](https://codepen.io/OttyLab/pen/ExzXVMp)


# コードを確認

まずExamplesのコードを見に行きましょう。

日本語サイト
@[card](https://docs.mapbox.com/jp/mapbox-gl-js/example/hillshade/)

英語サイト
@[card](https://docs.mapbox.com/mapbox-gl-js/example/hillshade/)

基本的に同じコードですが、英語版はMapbox Light v11スタイルを使用しているのでこちらを参照します。また、英語版はMapbox GL JS v3が使用されています。

## HTML/CSS

まずHTMLを見ていきましょう。

以下は地図を表示するエレメントです。

```HTML
<div id="map"></div>
```

## Mapの作成

次にJavaScriptのコードを見ていきます。以下のコードはいつも通り、Mapオブジェクトを作成しています。`container`で地図を表示するHTMLエレメントのidを指定します。

```JavaScript
const map = new mapboxgl.Map({
  container: 'map',
  // The Mapbox Light style doesn't contain hillshading.
  // You could also add it in Mapbox Studio.
  style: 'mapbox://styles/mapbox/light-v11',
  center: [-119.55, 37.71],
  zoom: 9
});
```

## ソースとレイヤーの作成

ソースとレイヤーを追加するので、`map.on('load', ()=> {/*ここ*/})`の中に処理を書きます。

まずはソースです。[Mapbox Terrain-DEM v1](https://docs.mapbox.com/data/tilesets/reference/mapbox-terrain-dem-v1/)を使用します。DEM (Digital Elevation Model) は各ピクセルの標高を色情報にエンコードしたものです。以前は[Mapbox Terrain-RGB v1](https://docs.mapbox.com/data/tilesets/reference/mapbox-terrain-rgb-v1/)を使用していましたが、今はMapbox Terrain-DEM v1の使用が推奨されます。ソースの`type`は[`raster-dem`](https://docs.mapbox.com/style-spec/reference/sources#raster-dem)を指定します。

```JavaScript
map.addSource('dem', {
  'type': 'raster-dem',
  'url': 'mapbox://mapbox.mapbox-terrain-dem-v1'
});
```

次はレイヤーです。先程のソースを使用します。レイヤーの`type`は[`hillshade`](https://docs.mapbox.com/style-spec/reference/layers#hillshade)を指定します。
```JavaScript
map.addLayer(
  {
    'id': 'hillshading',
    'source': 'dem',
    'type': 'hillshade'
  },
  // Insert below land-structure-polygon layer,
  // where hillshading sits in the Mapbox Streets style.
  'land-structure-polygon'
);
```

# まとめ

このサンプルでは`hillshade`レイヤーの使い方について確認しました。またMapbox Light v11スタイルはもともと以下のように`hillshade`がありません。

@[codepen](https://codepen.io/OttyLab/pen/abrwvxa)

`hillshade`をつけることで山の起伏がはっきりとわかりますね。ちなみに、Streets v12, Outdoors v12, Standard等のスタイルは`hillshade`があります。
