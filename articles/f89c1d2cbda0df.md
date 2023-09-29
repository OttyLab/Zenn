---
title: "Mapbox Newsletter WEEKLY TIPSの解説 -「マップの場所をスライドショーとして再生」"
emoji: "🛫"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Mapbox", "MapboxGLJS", "GIS", "JavaScript"]
published: true
publication_name: "mapbox_japan"
---

# はじめに

この記事は、先日配信されたMapbox NewsletterのWEEKLY TIPSで紹介されていた「マップの場所をスライドショーとして再生」についての解説です。このサンプルでは[`flytTo`](https://docs.mapbox.com/mapbox-gl-js/api/map/#map#flyto)や[`moveend`](https://docs.mapbox.com/mapbox-gl-js/api/map/#map.event:moveend)の使い方を紹介しています。また、Newsletterの購読は[こちら](https://www.mapbox.jp/blog?#:~:text=%E3%83%8B%E3%83%A5%E3%83%BC%E3%82%B9%E3%83%AC%E3%82%BF%E3%83%BC%E3%82%92%E8%B3%BC%E8%AA%AD)からお申し込みいただけます。


# コードを確認

まずExamplesのコードを見に行きましょう。

日本語サイト
@[card](https://docs.mapbox.com/jp/mapbox-gl-js/example/playback-locations/)

英語サイト
@[card](https://docs.mapbox.com/mapbox-gl-js/example/playback-locations/)

基本的に同じコードですが、英語版はスタイルがMapbox Streets v12にアップグレードされているのでこちらを使用します。Mapbox Streets v11ではデフォルトのプロジェクションがWebメルカトルであるのに対し、Mapbox Streets v12ではGlobe（3D表示された地球）なので、印象がかなり異なります。

## HTML/CSS

CSSとしては以下のスタイルを定義しています。

```CSS
.map-overlay-container {
  position: absolute;
  width: 25%;
  top: 0;
  left: 0;
  padding: 10px;
  z-index: 1;
}
 
.map-overlay {
  font: 12px/20px 'Helvetica Neue', Arial, Helvetica, sans-serif;
  background-color: #fff;
  border-radius: 3px;
  padding: 10px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
}
 
.map-overlay h2,
.map-overlay p {
  margin: 0 0 10px;
}
```

このスタイルは以下のHTMLのスタイリングに利用されています。これは、地図の左上に表示されている紹介文を表示する部分のエレメントです。

```HTML
<div class="map-overlay-container">
  <div class="map-overlay">
    <h2 id="location-title"></h2>
    <p id="location-description"></p>
    <small>Text credit:
      <a target="_blank" href="http://www.nycgo.com/neighborhoods">nycgo.com</a></small>
  </div>
</div>
```

また、以下は地図を表示するエレメントを作成しています。

```HTML
<div id="map"></div>
```

## Mapの作成

次にJavaScriptのコードを見ていきます。以下のコードはいつも通り、Mapオブジェクトを作成しています。`container`で地図を表示するHTMLエレメントのidを指定します。

```JavaScript
const map = new mapboxgl.Map({
  container: 'map',
  // Choose from Mapbox's core styles, or make your own style with Mapbox Studio
  style: 'mapbox://styles/mapbox/streets-v12',
  center: [-74.0315, 40.6989],
  maxZoom: 16,
  minZoom: 9,
  zoom: 9.68
});
```

## 紹介文のための処理
紹介文を表示するためにHTMLのエレメントを取得して`title`と`description`という変数でアクセスできるようにしています。

```JavaScript
const title = document.getElementById('location-title');
const description = document.getElementById('location-description');
```

## 各地点のデータ
次は、各地点のデータです。`title`, `description`および`camera`というデータが各地点に含まれているのがわかります。

```JavaScript
const locations = [
  {
    'id': '2',
    'title': 'The Bronx',
    'description':
    "This is where hip-hop was born, where the Yankees became a dynasty and where you can find New York City's leading zoo and botanical garden.",
    'camera': {
      center: [-73.8709, 40.8255],
      zoom: 12.21,
      pitch: 50
    }
  },
...
];
```

## ヘルパ関数の定義
ここでは2個のヘルパ関数が定義されています。

1つ目はレイヤーのフィルターを変更するためのヘルパ関数です。紹介文に該当するポリゴンのみが表示する処理を行います。具体的には、`highlight`レイヤーの`borocode`プロパティの値が`code`と一致するポリゴンのみが表示されるようになります。

```JavaScript
function highlightBorough(code) {
  // Only show the polygon feature that corresponds to `borocode` in the data.
  map.setFilter('highlight', ['==', 'borocode', code]);
}
```

2つ目はアニメーションの処理を行うためのヘルパ関数です。`title`と`description`をセットし、ポリゴンを表示させます。また`flyTo`でその地点にカメラ（視点）を移動させます。

[`map.once`](https://docs.mapbox.com/mapbox-gl-js/api/map/#map#once)はイベント発火時に**一度だけ**処理を行う際に使用します。[`map.on`](https://docs.mapbox.com/mapbox-gl-js/api/map/#map#on)はイベント発火時に**毎回**行われる処理を登録する機能なので、違いに注意しましょう。

また、ここでは[`moveend`](https://docs.mapbox.com/mapbox-gl-js/api/map/#map.event:moveend)イベントを使用しています。このイベントは地図上の移動が終了した際に発火します。`flyTo`は飛行機で離陸・着陸するようなアニメーションを伴う移動なので、ある程度の時間が必要です。そこで、`moveend`イベントでアニメーションが終了したことを検知し、その3秒後に`playback`を再度呼び出して次の地点へと移動します。

```JavaScript
function playback(index) {
  title.textContent = locations[index].title;
  description.textContent = locations[index].description;
   
  highlightBorough(locations[index].id ? locations[index].id : '');
   
  // Animate the map position based on camera properties.
  map.flyTo(locations[index].camera);
   
  map.once('moveend', () => {
    // Duration the slide is on screen after interaction.
    window.setTimeout(() => {
      // Increment index, looping back to the first after the last location.
      index = (index + 1) % locations.length;
      playback(index);
    }, 3000); // After callback, show the location for 3 seconds.
  });
}
```

## 紹介文の初期化
以下のコードで`text`および`description`の初期化を行っています。`locations`の最後の要素の値で初期化しています。
```JavaScript
// Display the last title/description first.
title.textContent = locations[locations.length - 1].title;
description.textContent = locations[locations.length - 1].description;
```
## ソース、レイヤーの作成

`load`イベント(`map.on('load', () => {})`の中身)で1つのソース、1つのレイヤーを追加しています。

まず、ソースを作成しています。[mapbox://mapbox.8ibmsn6u](https://studio.mapbox.com/tilesets/mapbox.8ibmsn6u/#9.5/40.7608/-73.9371)というベクタータイルセットを使用しています。`boroughs`というidのソースとして読み込んでいます。

```JavaScript
map.addSource('boroughs', {
  'type': 'vector',
  'url': 'mapbox://mapbox.8ibmsn6u'
});
```

このデータは、（画面を明るくしないと見にくいですが）以下のようにニューヨークの各自治区のポリゴンデータが含まれるベクタータイルセットです。また、先程出てきた`borocode`というプロパティがあることがわかります。レイヤー（ベクタータイルセットにおけるレイヤーとは、データのグループ名です）は`original`なので、`addLayer`の`source-layer`ではこの値を使用します。
![polygon](/images/articles/f89c1d2cbda0df/polygon.png)

次にレイヤーを`highlight`というidで作成しています。ソースとしては先程の`boroughs`を使用し、`fill`つまりポリゴンの色と不透明度を設定しています。また、フィルター（`filter`）のExpressionsは`['==', 'borocode', '']`となっているので一致するデータは存在しない、つまり表示されるポリゴンはありません。

```JavaScript
map.addLayer(
  {
    'id': 'highlight',
    'type': 'fill',
    'source': 'boroughs',
    'source-layer': 'original',
    'paint': {
      'fill-color': '#fd6b50',
      'fill-opacity': 0.25
    },
    'filter': ['==', 'borocode', '']
  },
  'road-label' // Place polygon under labels.
);
```

## アニメーションの開始

`playback`関数を呼び出すことでアニメーションを開始します。`playback`関数の中で`highlightBorough`が実行され、`map.setFilter('highlight', ['==', 'borocode', code]);`によってフィルタの条件が変わります。「`borocode`プロパティが`code`に一致するポリゴンを表示」というExpressionsになるので、該当するポリゴンのみが表示されます。

```JavaScript
playback(0);
```


# まとめ

[`flytTo`](https://docs.mapbox.com/mapbox-gl-js/api/map/#map#flyto)や[`moveend`](https://docs.mapbox.com/mapbox-gl-js/api/map/#map.event:moveend)の使い方を確認しました。少し長めのコードでしたが、要素を分解してみると簡単だったかと思います。


# おまけ
カメラコントロールの代表的なものに以下の3個があります。

- [`jumpTo`](https://docs.mapbox.com/mapbox-gl-js/api/map/#map#jumpto): 瞬間移動
- [`easeTo`](https://docs.mapbox.com/mapbox-gl-js/api/map/#map#easeto): スクロール
- [`flyTo`](https://docs.mapbox.com/mapbox-gl-js/api/map/#map#flyto): 離着陸


以下はこれらの動きを試すデモです。右上のボタンをクリックすると、東京駅・秋葉原駅間を移動します。
@[codepen](https://codepen.io/OttyLab/pen/xxmjzLo)
