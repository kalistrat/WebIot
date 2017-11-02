package com.vaadin;

import com.vaadin.ui.NativeSelect;
import com.vaadin.ui.themes.ValoTheme;

/**
 * Created by kalistrat on 02.11.2017.
 */
public class tNotificationConditionSelect extends NativeSelect {

    public tNotificationConditionSelect(){

        this.addItem("Измеряемая величина > критического значения");
        this.addItem("Измеряемая величина находится в интервале значений");
        this.addItem("Измеряемая величина < критического значения");

        this.select("Измеряемая величина > критического значения");
        this.setNullSelectionAllowed(false);

    }
}
