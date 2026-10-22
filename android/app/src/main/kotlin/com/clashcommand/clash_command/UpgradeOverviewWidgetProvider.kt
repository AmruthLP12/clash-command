package com.clashcommand.clash_command

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class UpgradeOverviewWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            try {
                val views = RemoteViews(context.packageName, R.layout.widget_upgrade_overview).apply {
                    val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java
                    )
                    setOnClickPendingIntent(R.id.widget_container, pendingIntent)

                    val villageName = widgetData.getString("village_name", null) ?: "Village"
                    val activeCount = widgetData.getInt("active_count", 0)
                    val hasUpgrades = widgetData.getBoolean("has_upgrades", false)

                    setTextViewText(R.id.tv_village_name, villageName)
                    setTextViewText(
                        R.id.tv_active_badge,
                        if (activeCount == 1) "1 Upgrading" else "$activeCount Upgrading"
                    )

                    if (hasUpgrades) {
                        val nearestName = widgetData.getString("nearest_name", null) ?: "Upgrade"
                        val nearestCategory = widgetData.getString("nearest_category", null) ?: ""
                        val nearestTime = widgetData.getString("nearest_time", null) ?: ""
                        val nearestProgress = widgetData.getInt("nearest_progress", 0)

                        setTextViewText(R.id.tv_upgrade_name, nearestName)
                        setTextViewText(R.id.tv_upgrade_category, nearestCategory)
                        setTextViewText(R.id.tv_upgrade_time, nearestTime)
                        setProgressBar(R.id.pb_upgrade_progress, 100, nearestProgress, false)

                        setViewVisibility(R.id.layout_active_upgrade, View.VISIBLE)
                        setViewVisibility(R.id.layout_empty_state, View.GONE)
                    } else {
                        setViewVisibility(R.id.layout_active_upgrade, View.GONE)
                        setViewVisibility(R.id.layout_empty_state, View.VISIBLE)
                    }
                }

                appWidgetManager.updateAppWidget(widgetId, views)
            } catch (t: Throwable) {
                Log.e("ClashCommandWidget", "Failed to update UpgradeOverview widget $widgetId", t)
            }
        }
    }
}

