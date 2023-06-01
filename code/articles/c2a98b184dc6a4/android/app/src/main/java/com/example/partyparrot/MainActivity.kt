package com.example.partyparrot

import android.graphics.BitmapFactory
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import com.mapbox.maps.MapView
import com.mapbox.maps.Style
import com.mapbox.maps.extension.style.image.image
import com.mapbox.maps.extension.style.layers.addLayer
import com.mapbox.maps.extension.style.layers.generated.SymbolLayer
import com.mapbox.maps.extension.style.layers.generated.symbolLayer
import com.mapbox.maps.extension.style.layers.getLayer
import com.mapbox.maps.extension.style.sources.addSource
import com.mapbox.maps.extension.style.sources.generated.GeoJsonSource
import com.mapbox.maps.extension.style.sources.generated.geoJsonSource
import com.mapbox.maps.extension.style.style

var mapView: MapView? = null

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        mapView = findViewById(R.id.mapView)
        mapView?.getMapboxMap()?.loadStyleUri(Style.LIGHT){
            it.addImage("parrot0", BitmapFactory.decodeResource(resources, R.drawable.frame0))
            it.addImage("parrot1", BitmapFactory.decodeResource(resources, R.drawable.frame1))
            it.addImage("parrot2", BitmapFactory.decodeResource(resources, R.drawable.frame2))
            it.addImage("parrot3", BitmapFactory.decodeResource(resources, R.drawable.frame3))
            it.addImage("parrot4", BitmapFactory.decodeResource(resources, R.drawable.frame4))
            it.addImage("parrot5", BitmapFactory.decodeResource(resources, R.drawable.frame5))
            it.addImage("parrot6", BitmapFactory.decodeResource(resources, R.drawable.frame6))
            it.addImage("parrot7", BitmapFactory.decodeResource(resources, R.drawable.frame7))
            it.addImage("parrot8", BitmapFactory.decodeResource(resources, R.drawable.frame8))
            it.addImage("parrot9", BitmapFactory.decodeResource(resources, R.drawable.frame9))

            val source = GeoJsonSource.Builder("party-source").url("asset://party.json").build()
            it.addSource(source)

            val layer = SymbolLayer("party-layer", "party-source")
            layer.iconImage("parrot0")
            layer.iconSize(0.25)
            it.addLayer(layer)

            var counter = 0;
            val handler = Handler(Looper.getMainLooper())
            handler.postDelayed(object: Runnable{
                override fun run() {
                    handler.postDelayed(this, 50)
                    layer.iconImage("parrot${(++counter) % 10}")
                }
            }, 100)
        }
    }

    override fun onStart() {
        super.onStart()
        mapView?.onStart()
    }

    override fun onStop() {
        super.onStop()
        mapView?.onStop()
    }

    override fun onLowMemory() {
        super.onLowMemory()
        mapView?.onLowMemory()
    }

    override fun onDestroy() {
        super.onDestroy()
        mapView?.onDestroy()
    }
}