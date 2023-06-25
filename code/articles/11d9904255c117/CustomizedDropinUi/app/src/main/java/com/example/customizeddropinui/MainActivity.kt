package com.example.customizeddropinui

import android.graphics.Color
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.ViewGroup
import androidx.transition.Fade
import androidx.transition.Scene
import androidx.transition.TransitionManager
import com.example.customizeddropinui.databinding.ActivityMainBinding
import com.example.customizeddropinui.databinding.CustomTripProgressBinding
import com.mapbox.maps.Style
import com.mapbox.navigation.core.MapboxNavigation
import com.mapbox.navigation.core.internal.extensions.flowRouteProgress
import com.mapbox.navigation.core.lifecycle.MapboxNavigationObserver
import com.mapbox.navigation.ui.base.lifecycle.UIBinder
import com.mapbox.navigation.ui.base.lifecycle.UIComponent
import com.mapbox.navigation.ui.maps.route.line.model.MapboxRouteLineOptions
import com.mapbox.navigation.ui.maps.route.line.model.RouteLineColorResources
import com.mapbox.navigation.ui.maps.route.line.model.RouteLineResources
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {
    lateinit var binding: ActivityMainBinding;

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.navigationView.api.routeReplayEnabled(true)

        binding.navigationView.customizeViewOptions {
            mapStyleUriDay = Style.SATELLITE_STREETS
            routeLineOptions = MapboxRouteLineOptions.Builder(applicationContext)
                .withRouteLineResources(
                    RouteLineResources.Builder()
                        .routeLineColorResources(
                            RouteLineColorResources.Builder()
                                .routeLowCongestionColor(Color.CYAN)
                                .routeUnknownCongestionColor(Color.MAGENTA)
                                .routeCasingColor(Color.RED)
                                .build()
                        )
                        .build()
                )
                .build()
        }

        binding.navigationView.customizeViewStyles {
            startNavigationButtonStyle = R.style.CustomStartNavigationButtonStyle
        }

        binding.navigationView.customizeViewBinders {
            infoPanelTripProgressBinder = CustomTripProgressViewBinder()
        }
    }
}

class CustomTripProgressComponent(private val binding: CustomTripProgressBinding) : UIComponent() {
    override fun onAttached(mapboxNavigation: MapboxNavigation) {
        super.onAttached(mapboxNavigation)
        coroutineScope.launch {
            mapboxNavigation.flowRouteProgress().collect {
                val ratio = it.distanceTraveled / (it.distanceTraveled + it.distanceRemaining)
                binding.messageTextView.text = when {
                    ratio < 0.8 -> "まだまだだよ"
                    else -> "もうすぐだよ"
                }
            }
        }
    }
}

class CustomTripProgressViewBinder : UIBinder {
    override fun bind(viewGroup: ViewGroup): MapboxNavigationObserver {
        val scene = Scene.getSceneForLayout(
            viewGroup,
            R.layout.custom_trip_progress,
            viewGroup.context
        )
        TransitionManager.go(scene, Fade())

        val binding = CustomTripProgressBinding.bind(viewGroup)
        return CustomTripProgressComponent(binding)
    }
}
