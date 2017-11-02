package com.vaadin;

import com.vaadin.ui.HorizontalLayout;
import com.vaadin.ui.Label;
import com.vaadin.ui.TextField;
import com.vaadin.ui.VerticalLayout;
import com.vaadin.ui.themes.ValoTheme;

import java.util.List;

/**
 * Created by kalistrat on 02.11.2017.
 */
public class tNotificationCriteriaField extends VerticalLayout {
    Integer sValueFrom;
    Integer sValueTill;
    Label prefixLabel;
    Label midfixLabel;
    TextField valueFromField;
    TextField valueTillField;
    boolean isInterval;

    public tNotificationCriteriaField(boolean eIsInterval){

        isInterval = eIsInterval;

        valueFromField = new TextField();
        valueFromField.addStyleName(ValoTheme.TEXTFIELD_BORDERLESS);
        valueFromField.setInputPrompt("0.00");
        valueFromField.setWidth("50px");
        sValueFrom = null;
        sValueTill = null;

        valueTillField = new TextField();
        valueTillField.addStyleName(ValoTheme.TEXTFIELD_BORDERLESS);
        valueTillField.setInputPrompt("0.00");
        valueTillField.setWidth("50px");

        prefixLabel = new Label();
        //prefixLabel.addStyleName("FormTextLabel");
        prefixLabel.setValue("c");

        midfixLabel = new Label();
        //midfixLabel.addStyleName("FormTextLabel");
        midfixLabel.setValue("по");

        if (isInterval) {
            HorizontalLayout fRow = new HorizontalLayout(prefixLabel,valueFromField);
            //fRow.setSizeUndefined();
            addComponent(fRow);
            HorizontalLayout sRow = new HorizontalLayout(midfixLabel,valueTillField);
            //sRow.setSizeUndefined();
            addComponent(sRow);

        } else {
            addComponent(valueFromField);
        }
    }

    public tNotificationCriteriaField(String sValue){

        valueFromField = new TextField();
        valueFromField.addStyleName(ValoTheme.TEXTFIELD_BORDERLESS);
        //valueFromField.setInputPrompt("0.00");
        valueFromField.setWidth("50px");

        valueTillField = new TextField();
        valueTillField.addStyleName(ValoTheme.TEXTFIELD_BORDERLESS);
        //valueTillTill.setInputPrompt("0.00");
        valueTillField.setWidth("50px");

        //System.out.println("tNotificationCriteriaField : sValue :" + sValue);


        List<String> sValues = tUsefulFuctions.GetListFromString(sValue,"|");
        if (sValues.size() == 2) {
            sValueFrom = Integer.parseInt(sValues.get(0));
            sValueTill = Integer.parseInt(sValues.get(1));
            valueFromField.setValue(sValues.get(0));
            valueTillField.setValue(sValues.get(1));
            isInterval = true;
        } else {
            sValueFrom = Integer.parseInt(sValue);
            valueFromField.setValue(sValue);
            isInterval =false;
        }

        prefixLabel = new Label();
        prefixLabel.addStyleName("CriteriaTextLabel");
        prefixLabel.setValue("c");

        midfixLabel = new Label();
        midfixLabel.addStyleName("CriteriaTextLabel");
        midfixLabel.setValue("по");

        if (isInterval) {
            HorizontalLayout fRow = new HorizontalLayout(prefixLabel,valueFromField);
            fRow.setSizeUndefined();
            fRow.addStyleName("CriteriaLayout");
            addComponent(fRow);
            HorizontalLayout sRow = new HorizontalLayout(midfixLabel,valueTillField);
            sRow.setSizeUndefined();
            sRow.addStyleName("CriteriaLayout");
            addComponent(sRow);
        } else {
            addComponent(valueFromField);
        }


    }


}
