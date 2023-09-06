---
title: "Mapbox Newsletter WEEKLY TIPSの解説 -「リアルタイムデータを追加」"
emoji: "🚀"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Mapbox", "MapboxGLJS", "GIS", "JavaScript"]
published: false
publication_name: "mapbox_japan"
---

# はじめに

この記事は、先日配信されたMapbox NewsletterのWEEKLY TIPSで紹介されていた「リアルタイムデータを追加」についての解説です。このサンプルでは国際宇宙ステーションの現在位置を2秒に1回取得し、地図上に現在位置を表示しています。また、Newsletterの購読は[こちら](https://www.mapbox.jp/blog?#:~:text=%E3%83%8B%E3%83%A5%E3%83%BC%E3%82%B9%E3%83%AC%E3%82%BF%E3%83%BC%E3%82%92%E8%B3%BC%E8%AA%AD)からお申し込みいただけます。


# コードを確認

まずExamplesのコードを見に行きましょう。

日本語サイト
@[card](https://docs.mapbox.com/jp/mapbox-gl-js/example/live-geojson/)

英語サイト
@[card](https://docs.mapbox.com/mapbox-gl-js/example/live-geojson/)

基本的に同じコードですが、英語版はスタイルがMapbox Streets v12にアップグレードされているのでこちらを使用します。Mapbox Streets v11ではデフォルトのプロジェクションがWebメルカトルであるのに対し、Mapbox Streets v12ではGlobe（3D表示された地球）なので、印象がかなり異なります。また、ロケットのアイコンも変更されています。

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
  // Choose from Mapbox's core styles, or make your own style with Mapbox Studio
  style: 'mapbox://styles/mapbox/streets-v12',
  zoom: 1.5
});
```

## コールバック

ソースおよびレイヤーの追加は`load`イベントのコールバックの中で行います。また、コールバックの中で`fetch`によるデータ取得を行う関係上、`async`としています。

```JavaScript
map.on('load', async () => {/*ここ*/});
```

## 国際宇宙ステーションの位置の取得

`getLocation`という関数を定義し、その中で位置情報を取得しています。具体的には`https://api.wheretheiss.at/v1/satellites/25544`というURLから`fetch`でデータを取得しています。レスポンスから`latitude`と`longitude`を取得し`map.flyTo`でカメラをその座標に移動させます。さらに、現在位置を座標とするポイントデータを含むGeoJSONを返しています。

```JavaScript
async function getLocation(updateSource) {
  // Make a GET request to the API and return the location of the ISS.
  try {
    const response = await fetch(
      'https://api.wheretheiss.at/v1/satellites/25544',
      { method: 'GET' }
    );
    const { latitude, longitude } = await response.json();
    // Fly the map to the location.
    map.flyTo({
      center: [longitude, latitude],
      speed: 0.5
    });
    // Return the location of the ISS as GeoJSON.
    return {
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'geometry': {
            'type': 'Point',
            'coordinates': [longitude, latitude]
          }
        }
      ]
    };
  } catch (err) {
    // If the updateSource interval is defined, clear the interval to stop updating the source.
    if (updateSource) clearInterval(updateSource);
    throw new Error(err);
  }
}
```

## ソースの追加

`getLocation`の戻り値は国際宇宙ステーションの位置を表すGeoJSONだったので、それをそのまま`addSource`の`data`として使用しています。

```JavaScript
// Get the initial location of the International Space Station (ISS).
const geojson = await getLocation();
// Add the ISS location as a source.
map.addSource('iss', {
  type: 'geojson',
  data: geojson
});
```

## レイヤーの追加

先程追加した`iss`をソースとするシンボルレイヤーを追加します。ロケットのアイコンを使用しています。

```JavaScript
// Add the rocket symbol layer to the map.
map.addLayer({
  'id': 'iss',
  'type': 'symbol',
  'source': 'iss',
  'layout': {
    // This icon is a part of the Mapbox Streets style.
    // To view all images available in a Mapbox style, open
    // the style in Mapbox Studio and click the "Images" tab.
    // To add a new image to the style at runtime see
    // https://docs.mapbox.com/mapbox-gl-js/example/add-image/
    'icon-image': 'rocket'
  }
});
```

## 更新

国際宇宙ステーションの位置を更新するため、`setInterval`で2秒ごとに`getLocation`を呼んでいます。位置情報は`setData`を用いて更新します。

```JavaScript
// Update the source from the API every 2 seconds.
const updateSource = setInterval(async () => {
  const geojson = await getLocation(updateSource);
  map.getSource('iss').setData(geojson);
}, 2000);
```

# まとめ
このサンプルのポイントは、定期的にデータを取得して`setData`でソースのデータを更新する部分でした。以下で解説しているサンプルも`setData`の使い方に関するものなので、合わせてご参照ください。

@[card](https://zenn.dev/ottylab/articles/e534052a464421/)


# おまけ

軌跡も描くようにしてみました。元のコードを最大限残すように記述しているので、若干冗長なコードになっています。

@[codepen](https://codepen.io/OttyLab/pen/JjwbePN)