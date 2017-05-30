package com.vaadin;

import com.vaadin.ui.TextField;
import com.vaadin.ui.VerticalLayout;
import com.vaadin.ui.themes.ValoTheme;

/**
 * Created by kalistrat on 30.05.2017.
 */
public class tTimeConditionLayout extends VerticalLayout {
    TextField TimeIntervalTextField;

    public tTimeConditionLayout(String sValue,boolean isTextFieldEnabled){

        TimeIntervalTextField = new TextField();
        TimeIntervalTextField.setValue(sValue);
        TimeIntervalTextField.addStyleName(ValoTheme.TEXTFIELD_TINY);
        TimeIntervalTextField.addStyleName(ValoTheme.TEXTFIELD_BORDERLESS);
        TimeIntervalTextField.setEnabled(isTextFieldEnabled);
        addComponent(TimeIntervalTextField);
        setMargin(false);
        setSizeUndefined();
    }
}
