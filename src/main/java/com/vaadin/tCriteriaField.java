package com.vaadin;

import com.vaadin.data.util.converter.Converter;
import com.vaadin.data.util.converter.StringToDoubleConverter;
import com.vaadin.data.util.converter.StringToIntegerConverter;
import com.vaadin.data.validator.DoubleRangeValidator;
import com.vaadin.data.validator.IntegerRangeValidator;
import com.vaadin.ui.DateField;
import com.vaadin.ui.HorizontalLayout;
import com.vaadin.ui.Label;
import com.vaadin.ui.TextField;
import com.vaadin.ui.themes.ValoTheme;
import org.vaadin.teemu.VaadinIcons;

import java.util.Locale;

/**
 * Created by kalistrat on 21.02.2017.
 */
public class tCriteriaField extends HorizontalLayout {

    TextField sMinField = new TextField();
    TextField sMaxField = new TextField();


    public tCriteriaField(String eTypeCriteria){

        sMinField.addStyleName(ValoTheme.TEXTFIELD_SMALL);
        sMaxField.addStyleName(ValoTheme.TEXTFIELD_SMALL);

        sMinField.setWidth("100px");
        sMinField.setIcon(VaadinIcons.CHEVRON_RIGHT);
        sMinField.setCaption("От");
        sMinField.setConverter(new StringToDoubleConverter());
        sMinField.addValidator(new DoubleRangeValidator("Значение может изменяться от -1000000 до 1000000", -1000000.0, 1000000.0));
        sMinField.setConversionError("Введённое значение не соответствует формату 0,00");
        sMinField.setNullRepresentation("");
        sMinField.setInputPrompt("0,00");


        sMaxField.setWidth("100px");
        sMaxField.setIcon(VaadinIcons.CHEVRON_LEFT);
        sMaxField.setCaption("До");
        sMaxField.setConverter(new StringToDoubleConverter());
        sMaxField.addValidator(new DoubleRangeValidator("Значение может изменяться от -1000000 до 1000000", -1000000.0, 1000000.0));
        sMaxField.setConversionError("Введённое значение не соответствует формату 0,00");
        sMaxField.setNullRepresentation("");
        sMaxField.setInputPrompt("0,00");

        if (eTypeCriteria.equals("интервал значений")) {
            this.addComponent(sMinField);
            this.addComponent(sMaxField);
        }

        if (eTypeCriteria.equals("полуинтервал значений >")) {
            this.addComponent(sMinField);
        }

        if (eTypeCriteria.equals("полуинтервал значений <")) {
            this.addComponent(sMaxField);
        }

        if (eTypeCriteria.equals("фиксированное значение =")) {
            sMaxField.setCaption("Равно");
            sMaxField.setIcon(null);
            this.addComponent(sMaxField);
        }

        this.setSpacing(true);
    }
}
