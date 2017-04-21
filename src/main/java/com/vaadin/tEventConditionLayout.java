package com.vaadin;

import com.vaadin.data.Property;
import com.vaadin.ui.NativeSelect;
import com.vaadin.ui.VerticalLayout;

import java.util.Arrays;
import java.util.List;

/**
 * Created by kalistrat on 17.02.2017.
 */
public class tEventConditionLayout extends VerticalLayout {

    NativeSelect TypeCriteriaSelect;
    tCriteriaField CriteriaValueLayout;

    public tEventConditionLayout(){

        List<String> SCriteriaList = Arrays.asList(new String[] {
                        "интервал значений"
                        , "полуинтервал значений >"
                        , "полуинтервал значений <"
                        , "фиксированное значение ="
                }
        );

        TypeCriteriaSelect = new NativeSelect("Тип условия",SCriteriaList);
        TypeCriteriaSelect.setNullSelectionAllowed(false);
        TypeCriteriaSelect.setValue("интервал значений");
        TypeCriteriaSelect.setImmediate(true);
        TypeCriteriaSelect.setEnabled(true);

        CriteriaValueLayout = new tCriteriaField("интервал значений");


        TypeCriteriaSelect.addValueChangeListener(new Property.ValueChangeListener() {
                 @Override
                 public void valueChange(Property.ValueChangeEvent e) {
                     String sCrType = (String) e.getProperty().getValue();
                     tCriteriaField CriteriaValueLayoutNew = new tCriteriaField(sCrType);
                     replaceComponent(CriteriaValueLayout,  CriteriaValueLayoutNew);
                     CriteriaValueLayout = CriteriaValueLayoutNew;
                 }
             }
        );

        this.setSpacing(true);

        this.addComponent(TypeCriteriaSelect);
        this.addComponent(CriteriaValueLayout);
    }
}
