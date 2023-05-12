---
title: "Mapbox Maps SDK Flutter Pluginでスタイル・レイヤーを操作する"
emoji: "😸"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Mapbox", "Flutter", "GIS"]
published: true
publication_name: "mapbox_japan"
---

# はじめに

この記事は[Mapbox Maps SDK Flutter Pluginを使ってみる](https://zenn.dev/ottylab/articles/d9ba57ca498170)の続きです。スタイルやレイヤーを操作してみます。

# 初期位置を設定する

初期位置は`cameraOptions`で設定します。以下のように`center`や`zoom`等が設定できます。centerは`toJson()`でJSONにしているのが少し奇妙な感じがします。`CameraOptions`の`center`が`Map<String?, Object?>`型ですが、`toJson()`を実行することで`Point`を`Map<String, dynamic>`に変換して型を合わせています。

```Dart
class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(
        resourceOptions: ResourceOptions(accessToken: YOUR_MAPBOX_PUBLIC_ACCESS_TOKEN),
        cameraOptions: CameraOptions(
          center: Point(coordinates: Position(139.7586677640881, 35.67369269880291)).toJson(),
          zoom: 14,
        ),
      )
    );
  }
}
```

ではなぜ`Map`で管理しているのかという疑問が湧いてきます。（あくまで私の予想ですが）メソッドチャネル経由でMapbox Maps SDK for Android/iOSにデータを渡す際に`Map<String, Any>`で渡し、ネイティブ側のオブジェクトに戻すという処理が行われいる都合上便利だからだと考えられます。しかし、内部の構造がユーザーのコードに滲み出ているのは少し気持ち悪い感じもします。

結果は以下のとおりです。

![Camera](/images/articles/48bc1a0b1acde2/camera.png)


# スタイルを設定する

次はスタイルを変更してみます。以下のように`styleUri`にURLを設定するだけでOKです。Mapboxが提供するコアスタイルは`MapboxStyles.LIGHT`のように指定することも可能です。これは内部で`mapbox://styles/mapbox/light-v10"`と定義されている定数です。

ここで指定したスタイルは[Mapboxのスタイルを体験する](https://zenn.dev/mapbox_japan/articles/28e581db08ca16)で使用したものです。

```Dart
class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(
        resourceOptions: ResourceOptions(accessToken: YOUR_MAPBOX_PUBLIC_ACCESS_TOKEN),
        cameraOptions: CameraOptions(
          center: Point(coordinates: Position(139.7586677640881, 35.67369269880291)).toJson(),
          zoom: 14,
        ),
        styleUri: "mapbox://styles/yochi/clgc8zfir000301pdahjtsax8",
      )
    );
  }
}
```

結果は以下のとおりです。少しわかりにくいですが、右下の道路が赤色になっています。

![Style](/images/articles/48bc1a0b1acde2/style.png)


# レイヤーを作る

[GeoJSONレイヤー表示における各地図サービスの比較](https://zenn.dev/mapbox_japan/articles/c7d08d14c4ed73#mapbox-gl-js)と同じGeoJSONレイヤーを作成してみましょう。

まず、`onMapCreated`を指定します。これはMapbox GL JSにおける`map.on('load', ()=>{})`に相当する処理です。

```Dart
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(
        resourceOptions: ResourceOptions(accessToken: YOUR_MAPBOX_PUBLIC_ACCESS_TOKEN),
        cameraOptions: CameraOptions(
          center: Point(coordinates: Position(139.7586677640881, 35.67369269880291)).toJson(),
          zoom: 16,
        ),
        styleUri: "mapbox://styles/yochi/clgc8zfir000301pdahjtsax8",
        onMapCreated: _onMapCreated,
      )
    );
  }
```

次に実際の処理を書きます。`addSource`でGeoJSONを追加し、`addLayer`でレイヤーを追加します。[Mapbox GL JSの記事](https://zenn.dev/mapbox_japan/articles/c7d08d14c4ed73#mapbox-gl-js)を見比べるとほぼ同じ処理であることがわかります。

```Dart
  _onMapCreated(MapboxMap mapboxMap) async {
    await mapboxMap.style.addSource(GeoJsonSource(id: "geojson_source", data: '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "coordinates": [
          [
            [139.75715452555397, 35.67501088740674],
            [139.75715452555397, 35.672275911172164],
            [139.7609465361483, 35.672275911172164],
            [139.7609465361483, 35.67501088740674],
            [139.75715452555397, 35.67501088740674]
          ]
        ],
        "type": "Polygon"
      }
    }
  ]
}
    '''));

    await mapboxMap.style.addLayerAt(FillLayer(
      id: "polygon_layer",
      sourceId: "geojson_source",
      fillColor: const Color(0xFF000088).value),
      LayerPosition(below: "building")
    );
  }
```

結果は以下のとおりです。

![Layer](/images/articles/48bc1a0b1acde2/layer.png)


# まとめ

Mapbox Maps SDK Flutter PluginでもMapbox GL JSと同じようにスタイルやレイヤーが操作できることがわかりました。Mapbox GL JSやMapbox Maps SDK for Androi/iOSに慣れている方は違和感なく使うことができるかと思います。
