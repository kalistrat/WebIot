package com.vaadin;

import com.vaadin.icons.VaadinIcons;
import com.vaadin.server.FontAwesome;
import com.vaadin.shared.ui.label.ContentMode;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

/**
 * Created by kalistrat on 13.05.2017.
 */
public class tDetectorFormLayout extends VerticalLayout {

    Button SaveButton;
    Button EditButton;
    TextField NameTextField;
    TextField UnitsTextField;
    NativeSelect PeriodMeasureSelect;
    TextField InTopicNameField;
    TextField OutTopicNameField;
    NativeSelect MqttServerSelect;

    public tDetectorFormLayout(){


        SaveButton = new Button();
        SaveButton.setIcon(FontAwesome.SAVE);
        SaveButton.addStyleName(ValoTheme.BUTTON_SMALL);
        SaveButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);

        EditButton = new Button();
        EditButton.setIcon(VaadinIcons.EDIT);
        EditButton.addStyleName(ValoTheme.BUTTON_SMALL);
        EditButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);

        NameTextField = new TextField("Наименование устройства :");
        UnitsTextField = new TextField("Единицы измерения :");
        PeriodMeasureSelect = new NativeSelect("Период снятия показаний :");
        InTopicNameField = new TextField("mqtt-топик для записи :");
        OutTopicNameField = new TextField("mqtt-топик для чтения :");
        MqttServerSelect = new NativeSelect("mqtt-сервер :");


        FormLayout dform = new FormLayout(
                NameTextField
                ,UnitsTextField
                ,PeriodMeasureSelect
                ,InTopicNameField
                ,OutTopicNameField
                ,MqttServerSelect
        );
        dform.addStyleName(ValoTheme.FORMLAYOUT_LIGHT);
        dform.setMargin(false);


        VerticalLayout dForm = new VerticalLayout(
                dform
        );
        dForm.addStyleName(ValoTheme.LAYOUT_CARD);
        //dForm.addStyleName(ValoTheme.LAYOUT_COMPONENT_GROUP);


        Label DetectorFormHeader = new Label();
        DetectorFormHeader.setContentMode(ContentMode.HTML);
        DetectorFormHeader.setValue(VaadinIcons.FORM.getHtml() + "  " + "Параметры измерительного устройства");
        DetectorFormHeader.addStyleName(ValoTheme.LABEL_COLORED);
        DetectorFormHeader.addStyleName(ValoTheme.LABEL_SMALL);

        HorizontalLayout FormHeaderButtons = new HorizontalLayout(
                EditButton
                ,SaveButton
        );
        FormHeaderButtons.setSpacing(true);
        FormHeaderButtons.setSizeUndefined();

        HorizontalLayout FormHeaderLayout = new HorizontalLayout(
                DetectorFormHeader
                ,FormHeaderButtons
        );
        FormHeaderLayout.setSizeFull();
        FormHeaderLayout.setComponentAlignment(DetectorFormHeader,Alignment.MIDDLE_LEFT);
        FormHeaderLayout.setComponentAlignment(FormHeaderButtons,Alignment.MIDDLE_RIGHT);



        VerticalLayout ContentLayout = new VerticalLayout(
                FormHeaderLayout
                ,dForm
        );
        ContentLayout.setSpacing(true);
        //ContentLayout.setSizeFull();

        this.addComponent(ContentLayout);


    }
}
