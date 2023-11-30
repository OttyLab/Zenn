---
title: "Mapbox Newsletter WEEKLY TIPSの解説 -「マップの言語を変更」"
emoji: "🗣️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Mapbox", "MapboxGLJS", "GIS", "JavaScript"]
published: true
publication_name: "mapbox_japan"
---

# はじめに

この記事は、先日配信されたMapbox NewsletterのWEEKLY TIPSで紹介されていた「マップの言語を変更」についての解説です。Mapbox Streets v8ベクタータイルセットは多言語対応なので簡単に表示する言語を切り替えることができます。また、Newsletterの購読は[こちら](https://www.mapbox.jp/blog?#:~:text=%E3%83%8B%E3%83%A5%E3%83%BC%E3%82%B9%E3%83%AC%E3%82%BF%E3%83%BC%E3%82%92%E8%B3%BC%E8%AA%AD)からお申し込みいただけます。

以下が本サンプルのデモです。

@[codepen](https://codepen.io/OttyLab/pen/XWOPZdo)


# コードを確認

まずExamplesのコードを見に行きましょう。

日本語サイト
@[card](https://docs.mapbox.com/jp/mapbox-gl-js/example/language-switch/)

英語サイト
@[card](https://docs.mapbox.com/mapbox-gl-js/example/language-switch/)

基本的に同じコードですが、英語版はスタイルがMapbox Light v11にアップグレードされているのでこちらを使用します。Mapbox Light v10ではデフォルトのプロジェクションがWebメルカトルであるのに対し、Mapbox Light v11ではGlobe（3D表示された地球）なので、印象がかなり異なります。

## HTML/CSS

まずCSSです。

以下はボタンをまとめる`ul`タグのスタイルです。

```css
#buttons {
  width: 90%;
  margin: 0 auto;
}
```

以下は各ボタンを表現する`li`タグのスタイルです。

```css
.button {
  display: inline-block;
  position: relative;
  cursor: pointer;
  width: 20%;
  padding: 8px;
  border-radius: 3px;
  margin-top: 10px;
  font-size: 12px;
  text-align: center;
  color: #fff;
  background: #ee8a65;
  font-family: sans-serif;
  font-weight: bold;
}
```

次にHTMLです。

以下は地図を表示するエレメントを作成しています。

```HTML
<div id="map"></div>
```

以下はボタンです。

```HTML
<ul id="buttons">
<li id="button-fr" class="button">French</li>
<li id="button-ru" class="button">Russian</li>
<li id="button-de" class="button">German</li>
<li id="button-es" class="button">Spanish</li>
</ul>
```

## Mapの作成

JavaScriptのコードを見ていきます。以下のコードはいつも通り、Mapオブジェクトを作成しています。`container`で地図を表示するHTMLエレメントのidを指定します。

```JavaScript
const map = new mapboxgl.Map({
  container: 'map',
  // Choose from Mapbox's core styles, or make your own style with Mapbox Studio
  style: 'mapbox://styles/mapbox/light-v11',
  center: [16.05, 48],
  zoom: 2.9
});
```

次にボタンクリック時の動作を記述します。

`getElementById`で`buttons`エレメント（ボタンをまとめる`ul`タグ）を取得し、それに対し`addEventListener`で`click`イベントの処理を記述します。
```JavaScript
document.getElementById('buttons').addEventListener('click', (event) => {
  //中身
});
```

`ul`に対するクリックイベントですが、子要素の`li`がクリックされると`event.target.id`には`li`の`id`が格納されています。`id`の`button-`という文字列を削除したものが`language`に格納されます。これは`button-`の`length`分を飛ばした位置を開始位置とする文字列を取得しているためです。
```JavaScript
const language = event.target.id.substr('button-'.length);
```

[`Map#setLayoutProperty`](https://docs.mapbox.com/mapbox-gl-js/api/map/#map#setlayoutproperty)は第一引数にレイヤーID、第二引数に変更したいレイヤープロパティの名称、第三引数に変更後の値を入れます。`country-label`はシンボルレイヤーなので、文字列ラベルは[`text-field`](https://docs.mapbox.com/style-spec/reference/layers/#layout-symbol-text-field)プロパティで指定します。この値を言語コードに対応したソースプロパティから読んできます。

例えば、Frenchがクリックされた場合、`country-label`の`text-field`プロパティに対し、`['get', 'name_fr']`という値が使用されます。

```JavaScript
map.setLayoutProperty('country-label', 'text-field', [
  'get',
  `name_${language}`
]);
```

実際、データを見てみると`name_言語コード`というプロパティが入っています。
![country label](/images/articles/3cdeaef4738bd8/country-label.png)

サポートされている言語一覧については[こちら](https://docs.mapbox.com/data/tilesets/reference/mapbox-streets-v8/#names)をご参照ください。


# まとめ

元のデータが多言語対応だったので、`setLayoutProerty`で参照するソースプロパティを切り替えるだけで言語を変更できました。だたし、今回は`country-label`のみ変更したので、都市名等は英語のままです。すべての表示言語を切り替えるためには`state-label`等、関連するレイヤー全てに対し同様の変更が必要です。