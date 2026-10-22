package com.clashcommand.clash_command

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class BuilderStatusWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            try {
                val views = RemoteViews(context.packageName, R.layout.widget_builder_status).apply {
                    val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java
                    )
                    setOnClickPendingIntent(R.id.widget_container, pendingIntent)

                    val villageName = widgetData.getString("village_name", null) ?: "Village"
                    val totalBuilders = widgetData.getInt("total_builders", 5)
                    val availableBuilders = widgetData.getInt("available_builders", 0)
                    val busyBuilders = widgetData.getInt("busy_builders", 0)
                    val occupancyText = widgetData.getString("builder_occupancy_text", null)
                        ?: "All builders are resting."

                    setTextViewText(R.id.tv_builder_village_name, villageName)
                    setTextViewText(R.id.tv_available_builders, "$availableBuilders Free")
                    setTextViewText(R.id.tv_busy_builders, "$busyBuilders Busy")
                    setTextViewText(R.id.tv_total_builders, "of $totalBuilders total")
                    setTextViewText(R.id.tv_builder_occupancy, occupancyText)
                }

                appWidgetManager.updateAppWidget(widgetId, views)
            } catch (t: Throwable) {
                Log.e("ClashCommandWidget", "Failed to update BuilderStatus widget $widgetId", t)
            }
        }
    }
}

