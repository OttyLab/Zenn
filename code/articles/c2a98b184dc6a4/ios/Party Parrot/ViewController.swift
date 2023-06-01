//
//  ViewController.swift
//  Party Parrot
//
//  Created by Yoshikage Ochi on 2023/06/01.
//

import UIKit
import MapboxMaps


class ViewController: UIViewController {
    internal var mapView: MapView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let resourceOptions = ResourceOptions(accessToken: YOUR_MAPBOX_PUBLIC_TOKEN)
        let centerCoordinate = CLLocationCoordinate2D(latitude: 35.6811649, longitude: 139.763906)
        let mapInitOptions = MapInitOptions(
            resourceOptions: resourceOptions,
            cameraOptions: CameraOptions(center: centerCoordinate, zoom: 14.0),
            styleURI: .light)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.view.addSubview(mapView)
        
        mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            try! self.mapView.mapboxMap.style.addImage(UIImage(named: "frame0")!, id: "parrot0")
            try! self.mapView.mapboxMap.style.addImage(UIImage(named: "frame1")!, id: "parrot1")
            try! self.mapView.mapboxMap.style.addImage(UIImage(named: "frame2")!, id: "parrot2")
            try! self.mapView.mapboxMap.style.addImage(UIImage(named: "frame3")!, id: "parrot3")
            try! self.mapView.mapboxMap.style.addImage(UIImage(named: "frame4")!, id: "parrot4")
            try! self.mapView.mapboxMap.style.addImage(UIImage(named: "frame5")!, id: "parrot5")
            try! self.mapView.mapboxMap.style.addImage(UIImage(named: "frame6")!, id: "parrot6")
            try! self.mapView.mapboxMap.style.addImage(UIImage(named: "frame7")!, id: "parrot7")
            try! self.mapView.mapboxMap.style.addImage(UIImage(named: "frame8")!, id: "parrot8")
            try! self.mapView.mapboxMap.style.addImage(UIImage(named: "frame9")!, id: "parrot9")
            
            guard let featureCollection = try? self.decodeGeoJSON(from: "party") else { return }
            var source = GeoJSONSource()
            source.data = .featureCollection(featureCollection)
            try! self.mapView.mapboxMap.style.addSource(source, id: "party-source")
            
            var layer = SymbolLayer(id: "party-layer")
            layer.source = "party-source"
            layer.iconImage = .constant(.name("parrot0"))
            layer.iconSize = .constant(0.25)
            try! self.mapView.mapboxMap.style.addLayer(layer)
            
            var counter = 0;
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { _ in
                counter += 1
                try! self.mapView.mapboxMap.style.updateLayer(withId: "party-layer", type: SymbolLayer.self) { layer in
                    layer.iconImage = .constant(.name("parrot\(counter % 10)"))
                }
            })
        }
    }
    
    internal func decodeGeoJSON(from fileName: String) throws -> FeatureCollection? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            preconditionFailure("File '\(fileName)' not found.")
        }

        let filePath = URL(fileURLWithPath: path)

        var featureCollection: FeatureCollection?

        do {
            let data = try Data(contentsOf: filePath)
            featureCollection = try JSONDecoder().decode(FeatureCollection.self, from: data)
        } catch {
            print("Error parsing data: \(error)")
        }

        return featureCollection
    }
}
