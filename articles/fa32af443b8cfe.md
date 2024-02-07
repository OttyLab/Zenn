---
title: "Mapbox Newsletter WEEKLY TIPSの解説 -「ゲーム感覚でマップを操作」"
emoji: "🎮"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Mapbox", "MapboxGLJS", "GIS", "JavaScript"]
published: true
publication_name: "mapbox_japan"
---

# はじめに

この記事は、先日配信されたMapbox NewsletterのWEEKLY TIPSで紹介されていた「ゲーム感覚でマップを操作」についての解説です。このサンプルはデフォルトとは異なるキーボード操作を実装する方法について例示しています。また、Newsletterの購読は[こちら](https://www.mapbox.jp/blog?#:~:text=%E3%83%8B%E3%83%A5%E3%83%BC%E3%82%B9%E3%83%AC%E3%82%BF%E3%83%BC%E3%82%92%E8%B3%BC%E8%AA%AD)からお申し込みいただけます。

以下が本サンプルのデモです。キーボードの矢印キーで操作します。上下矢印で前後の移動、左右矢印で地図の回転です。

@[codepen](https://codepen.io/OttyLab/pen/rNRGeoM)


# コードを確認

まずExamplesのコードを見に行きましょう。

日本語サイト
@[card](https://docs.mapbox.com/jp/mapbox-gl-js/example/game-controls/)

英語サイト
@[card](https://docs.mapbox.com/mapbox-gl-js/example/game-controls/)

基本的に同じコードですが、英語版はスタイルがMapbox Dark v11にアップグレードされているのでこちらを使用します。Mapbox Dark v10ではデフォルトのプロジェクションがWebメルカトルであるのに対し、Mapbox Dark v11ではGlobe（3D表示された地球）なので、印象がかなり異なります。また、英語版はMapbox GL JS v3が使用されています。

## HTML/CSS

まずHTMLを見ていきましょう。

以下は地図を表示するエレメントです。

```HTML
<div id="map"></div>
```

## Mapの作成

JavaScriptのコードを見ていきます。以下のコードはいつも通り、Mapオブジェクトを作成しています。`container`で地図を表示するHTMLエレメントのidを指定します。また、`interactive: false`とすることで、キーボード・マウスによる入力を一切受け付けなくなります。

```JavaScript
const map = new mapboxgl.Map({
  container: 'map',
  // Choose from Mapbox's core styles, or make your own style with Mapbox Studio
  style: 'mapbox://styles/mapbox/dark-v11',
  center: [-87.6298, 41.8781],
  zoom: 17,
  bearing: -12,
  pitch: 60,
  interactive: false
});
```

## キーボードの処理
地図がロードされた後（`map.on('load', () => {/* ここ */})`）、キーボード操作に関する処理を登録します。

### 前処理
地図が描画されているCanvasにフォーカスを移動させています。また、Mapbox GL JS v3では`map.getCanvas().setAttribute('tabindex', '0');`を追加する必要があります。`tabindex`を指定しないとCanvasにフォーカスが当たらず、キーボード入力がCanvasに到達しません

```JavaScript
map.getCanvas().setAttribute('tabindex', '0'); // v3では必要
map.getCanvas().focus();
```

背景としては以下のとおりです。

v2.15.0までは、以下のように`interactive`の状態にかかわらず`tabindex`が設定されていました。

https://github.com/mapbox/mapbox-gl-js/blob/v2.15.0/src/ui/map.js#L2934-L2943

v3.0.0からは、以下のように`interactive`が`true`のときにだけ`tabindex`が設定されます。
https://github.com/mapbox/mapbox-gl-js/blob/v3.0.0/src/ui/map.js#L3270-L3273

当サンプルコードでは`interactive: false`としているので、そのままでは`tabindex`が設定されません。そこで、ユーザーコード側で追加する必要があります。

### イベントリスナの設定
ここからは実際のキーボードの処理を記述します。`Map` オブジェクトとしてキーボード入力を処理するのではなく、Canvasに対するキーボード入力を処理します。そのため、`map.getCanvas().addEventListener('keydown', (e) => {/* ここ */})`の「ここ」の部分に入力されたキーに対応した処理を記述します。

以下のように、キーコードに応じて処理を分岐します。up/downは[`Map#panBy`](https://docs.mapbox.com/mapbox-gl-js/api/map/#map#panby)でカメラをY軸方向に、right/leftは[`Map#easeTo`](https://docs.mapbox.com/mapbox-gl-js/api/map/#map#easeto)で`bearing`を指定することでその場を中心にカメラを回転させています。

```JavaScript
e.preventDefault();
if (e.which === 38) {
  // up
  map.panBy([0, -deltaDistance], {
    easing: easing
  });
} else if (e.which === 40) {
  // down
  map.panBy([0, deltaDistance], {
    easing: easing
  });
} else if (e.which === 37) {
  // left
  map.easeTo({
    bearing: map.getBearing() - deltaDegrees,
    easing: easing
  });
} else if (e.which === 39) {
  // right
  map.easeTo({
    bearing: map.getBearing() + deltaDegrees,
    easing: easing
  });
}
```

`Map#panBy`はスクリーン座標（画面のピクセルとしてのXY座標）上でカメラを移動します。第一引数で`[x,y]`を指定します。ここではxを0,yを`+/-deltaDistance`(100ピクセル)とすることでカメラを上下方向に移動させます。`Map#easeTo`では`bearing`において`map.getBearing()`で現在の`bearing`（向いている方向、北が0）を取得し、それに対し`deltaDegrees`(25°)加減算することでカメラを回転させます。

また、`easing`にはイージング関数を指定します。これは引数として[0, 1]の時間をとり、[0, 1]の値を出力する関数で、アニメーションの制御に使用します。例えば、(0, 0) (1, 1)を通る一次関数として定義すると、時間変化と同じ割合で出力が変化するため、一定速度でアニメーションが実行されます。ここでは以下のようにx座標が1のときに最大値1となる上に凸な二次関数が定義されています。そのため、最初は勢いよく、最後はゆっくりアニメーションします。

```JavaScript
function easing(t) {
    return t * (2 - t);
}
```


# まとめ
デフォルトのキーボード・マウス入力を受け付けない状態にし、Canvasのイベントハンドラとして実装するとこで任意のキーボード操作が可能になりました。


# 2024/02/07 追記

英語サイトのデモが修正されました。
@[card](https://docs.mapbox.com/mapbox-gl-js/example/game-controls/)

この記事でご紹介した`map.getCanvas().setAttribute('tabindex', '0'); `を追加する方法ではなく、以下のように`interactive: true`（デフォルトなので省略）とした上で、すべての入力系のハンドラーを`false`にしています。

```JavaScript
const map = new mapboxgl.Map({
  container: 'map',
  // Choose from Mapbox's core styles, or make your own style with Mapbox Studio
  style: 'mapbox://styles/mapbox/dark-v11',
  center: [-87.6298, 41.8781],
  zoom: 17,
  bearing: -12,
  pitch: 60,
  boxZoom: false,
  doubleClickZoom: false,
  dragPan: false,
  dragRotate: false,
  keyboard: false,
  scrollZoom: false,
  touchPitch: false,
  touchZoomRotate: false
});
```

この方法のメリットは、Mapbox GL JSの内部の実装に関する知識が不要であるという点です。

ただし、`interactive: true`の時、マウスカーソルが`grab`（手の形）になります。今回はマウス入力を無効化しているのでデフォルト（矢印）にしたいのですが、変更するAPIがありません。そこでデモでは以下のように強引に変更しています。これはMapbox GL JSの内部の実装に関する知識が必要となるため、マウスカーソルを変更するAPIの実装が待たれます。

```JavaScript
map.getCanvas().parentNode.classList.remove('mapboxgl-interactive');
```
