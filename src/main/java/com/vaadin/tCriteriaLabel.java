package com.vaadin;

import com.vaadin.ui.Label;


/**
 * Created by kalistrat on 17.02.2017.
 */
public class tCriteriaLabel extends Label {

    public tCriteriaLabel(String eTypeCriteria, Double eValMin, Double eValMax){


        if (eTypeCriteria.equals("интервал значений")) {
            String sMinVal = String.valueOf(eValMin);
            String LabelVal = " < Значение < ";
            String sMaxVal = String.valueOf(eValMax);
            this.setValue(sMinVal + LabelVal + sMaxVal);
        }

        if (eTypeCriteria.equals("полуинтервал значений >")) {
            String sMinVal = String.valueOf(eValMin);
            String LabelVal = "Значение > ";
            this.setValue(LabelVal + sMinVal);
        }

        if (eTypeCriteria.equals("полуинтервал значений <")) {
            String sMaxVal = String.valueOf(eValMax);
            String LabelVal = "Значение < ";
            this.setValue(LabelVal + sMaxVal);
        }

        if (eTypeCriteria.equals("фиксированное значение =")) {
            String sMaxVal = String.valueOf(eValMax);
            String LabelVal = "Значение = ";
            this.setValue(LabelVal + sMaxVal);
        }


    }
}
