package com.vaadin;

import com.vaadin.icons.VaadinIcons;
import com.vaadin.ui.Label;
import com.vaadin.ui.VerticalLayout;
import org.eclipse.paho.client.mqttv3.*;

import java.sql.Timestamp;

/**
 * Created by kalistrat on 21.04.2017.
 */
public class tMqttClientLayout extends VerticalLayout {

    public tMqttClientLayout(){



        this.addComponent(new Label("Здесь будет MQTT"));
        this.setMargin(true);
    }
}
