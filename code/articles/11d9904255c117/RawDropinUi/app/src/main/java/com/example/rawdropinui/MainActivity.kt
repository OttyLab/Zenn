package com.example.rawdropinui

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.mapbox.navigation.dropin.NavigationView

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val navigationView: NavigationView = findViewById(R.id.navigationView)
        navigationView.api.routeReplayEnabled(true)
    }
}