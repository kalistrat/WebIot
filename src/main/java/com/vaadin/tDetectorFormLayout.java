package com.vaadin;

import com.vaadin.icons.VaadinIcons;
import com.vaadin.server.FontAwesome;
import com.vaadin.shared.ui.label.ContentMode;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

import java.sql.*;
import java.text.DateFormat;
import java.text.SimpleDateFormat;

/**
 * Created by kalistrat on 13.05.2017.
 */
public class tDetectorFormLayout extends VerticalLayout {

    Button SaveButton;
    Button EditButton;
    TextField NameTextField;
    //TextField UnitsTextField;
    NativeSelect PeriodMeasureSelect;
    TextField DetectorAddDate;
    TextField InTopicNameField;
    NativeSelect MqttServerSelect;
    int iUserDeviceId;

    TextField DeviceLoginTextField;
    TextField DevicePassWordTextField;

    public tDetectorFormLayout(int eUserDeviceId){

        iUserDeviceId = eUserDeviceId;

        SaveButton = new Button();
        SaveButton.setIcon(FontAwesome.SAVE);
        SaveButton.addStyleName(ValoTheme.BUTTON_SMALL);
        SaveButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);
        SaveButton.setEnabled(false);

        SaveButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                String sErrorMessage = "";
                String sDeviceLog = DeviceLoginTextField.getValue();
                String sDevicePass = DevicePassWordTextField.getValue();

                if (sDeviceLog == null){
                    sErrorMessage = "Логин устройства не задан\n";
                }

                if (sDeviceLog.equals("")){
                    sErrorMessage = sErrorMessage + "Логин устройства не задан\n";
                }

                if (sDeviceLog.length() > 25){
                    sErrorMessage = sErrorMessage + "Длина логина превышает 25 символов\n";
                }

                if (sDevicePass == null){
                    sErrorMessage = "Пароль устройства не задан\n";
                }

                if (sDevicePass.equals("")){
                    sErrorMessage = sErrorMessage + "Пароль устройства не задан\n";
                }

                if (sDevicePass.length() > 25){
                    sErrorMessage = sErrorMessage + "Длина пароля превышает 25 символов\n";
                }

                if (!tUsefulFuctions.IsLatinAndDigits(sDeviceLog)){
                    sErrorMessage = sErrorMessage + "Указанный логин недопустим. Он должен состоять из букв латиницы и цифр\n";
                }

                if (!tUsefulFuctions.IsLatinAndDigits(sDevicePass)){
                    sErrorMessage = sErrorMessage + "Указанный пароль недопустим. Он должен состоять из букв латиницы и цифр\n";
                }

                if (!sErrorMessage.equals("")){
                    Notification.show("Ошибка сохранения:",
                            sErrorMessage,
                            Notification.Type.TRAY_NOTIFICATION);
                } else {
                    tUsefulFuctions.updateActuatorLoginPassWord(iUserDeviceId,sDeviceLog,sDevicePass);
                    updateDetectorMeasurePeriod();
                    SaveButton.setEnabled(false);
                    EditButton.setEnabled(true);
                    DeviceLoginTextField.setEnabled(false);
                    DevicePassWordTextField.setEnabled(false);
                    PeriodMeasureSelect.setEnabled(false);
                }

            }
        });

        EditButton = new Button();
        EditButton.setIcon(VaadinIcons.EDIT);
        EditButton.addStyleName(ValoTheme.BUTTON_SMALL);
        EditButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);

        EditButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                SaveButton.setEnabled(true);
                EditButton.setEnabled(false);
                //UnitsTextField.setEnabled(true);
                PeriodMeasureSelect.setEnabled(true);
                DeviceLoginTextField.setEnabled(true);
                DevicePassWordTextField.setEnabled(true);
            }
        });

        NameTextField = new TextField("Наименование устройства :");
        NameTextField.setEnabled(false);
        //UnitsTextField = new TextField("Единицы измерения :");
        //UnitsTextField.setEnabled(false);
        PeriodMeasureSelect = new NativeSelect("Период измерений :");
        PeriodMeasureSelect.setEnabled(false);
        PeriodMeasureSelect.addItem("ежесекундно");
        PeriodMeasureSelect.addItem("ежеминутно");
        PeriodMeasureSelect.addItem("ежечасно");
        PeriodMeasureSelect.addItem("ежедневно");
        PeriodMeasureSelect.addItem("еженедельно");
        PeriodMeasureSelect.addItem("ежемесячно");
        PeriodMeasureSelect.addItem("ежегодно");
        PeriodMeasureSelect.addItem("не задано");
        PeriodMeasureSelect.setNullSelectionAllowed(false);
        PeriodMeasureSelect.select("не задано");


        DetectorAddDate = new TextField("Дата добавления устройства :");
        DetectorAddDate.setEnabled(false);
        InTopicNameField = new TextField("mqtt-топик для записи :");
        InTopicNameField.setEnabled(false);
        MqttServerSelect = new NativeSelect("mqtt-сервер :");
        MqttServerSelect.setNullSelectionAllowed(false);
        MqttServerSelect.setEnabled(false);

        DeviceLoginTextField = new TextField("Логин устройства :");
        DevicePassWordTextField = new TextField("Пароль устройства :");

        DeviceLoginTextField.setEnabled(false);
        DevicePassWordTextField.setEnabled(false);

        tUsefulFuctions.getMqttServerData(MqttServerSelect);


        FormLayout dform = new FormLayout(
                NameTextField
                //,UnitsTextField
                ,PeriodMeasureSelect
                ,DetectorAddDate
                ,InTopicNameField
                ,MqttServerSelect
                ,DeviceLoginTextField
                ,DevicePassWordTextField
        );
        dform.addStyleName(ValoTheme.FORMLAYOUT_LIGHT);
        dform.addStyleName("FormFont");

        dform.setMargin(false);


        VerticalLayout dForm = new VerticalLayout(
                dform
        );
        dForm.addStyleName(ValoTheme.LAYOUT_CARD);
        dForm.setWidth("100%");
        dForm.setHeightUndefined();



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
        FormHeaderLayout.setWidth("100%");
        FormHeaderLayout.setHeightUndefined();
        FormHeaderLayout.setComponentAlignment(DetectorFormHeader,Alignment.MIDDLE_LEFT);
        FormHeaderLayout.setComponentAlignment(FormHeaderButtons,Alignment.MIDDLE_RIGHT);



        VerticalLayout ContentLayout = new VerticalLayout(
                FormHeaderLayout
                ,dForm
        );
        ContentLayout.setSpacing(true);
        ContentLayout.setWidth("100%");
        ContentLayout.setHeightUndefined();

        this.addComponent(ContentLayout);
        //this.addStyleName(ValoTheme.LAYOUT_WELL);


    }



    public void updateDetectorMeasurePeriod(){
        try {

            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            CallableStatement Stmt = Con.prepareCall("{call p_device_measure_period(?, ?)}");
            Stmt.setInt(1, iUserDeviceId);
            Stmt.setString(2, (String) PeriodMeasureSelect.getValue());

            Stmt.execute();

            Con.close();

        }catch(SQLException se){
            //Handle errors for JDBC
            se.printStackTrace();
        }catch(Exception e) {
            //Handle errors for Class.forName
            e.printStackTrace();
        }

    }


}
