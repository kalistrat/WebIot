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
    TextField UnitsTextField;
    NativeSelect PeriodMeasureSelect;
    TextField DetectorAddDate;
    TextField InTopicNameField;
    NativeSelect MqttServerSelect;
    int iUserDeviceId;

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
                SaveButton.setEnabled(false);
                EditButton.setEnabled(true);
                UnitsTextField.setEnabled(false);
                PeriodMeasureSelect.setEnabled(false);
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
                UnitsTextField.setEnabled(true);
                PeriodMeasureSelect.setEnabled(true);
            }
        });

        NameTextField = new TextField("Наименование устройства :");
        NameTextField.setEnabled(false);
        UnitsTextField = new TextField("Единицы измерения :");
        UnitsTextField.setEnabled(false);
        PeriodMeasureSelect = new NativeSelect("Период измерений :");
        PeriodMeasureSelect.setEnabled(false);
        PeriodMeasureSelect.addItem("ежесекундно");
        PeriodMeasureSelect.addItem("ежеминутно");
        PeriodMeasureSelect.addItem("ежечасно");
        PeriodMeasureSelect.addItem("ежедневно");
        PeriodMeasureSelect.addItem("еженедельно");
        PeriodMeasureSelect.addItem("ежемесячно");
        PeriodMeasureSelect.addItem("ежегодно");
        PeriodMeasureSelect.setNullSelectionAllowed(false);


        DetectorAddDate = new TextField("Дата добавления устройства :");
        DetectorAddDate.setEnabled(false);
        InTopicNameField = new TextField("mqtt-топик для записи :");
        InTopicNameField.setEnabled(false);
        MqttServerSelect = new NativeSelect("mqtt-сервер :");
        MqttServerSelect.setNullSelectionAllowed(false);
        MqttServerSelect.setEnabled(false);


        getMqttServerData();


        FormLayout dform = new FormLayout(
                NameTextField
                ,UnitsTextField
                ,PeriodMeasureSelect
                ,DetectorAddDate
                ,InTopicNameField
                ,MqttServerSelect
        );
        dform.addStyleName(ValoTheme.FORMLAYOUT_LIGHT);
        dform.addStyleName("FormFont");

        dform.setMargin(false);

        getUserDetectorData();


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

    public void getUserDetectorData(){

        DateFormat df = new SimpleDateFormat("dd.MM.yyyy");


        try {
            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            String DataSql = "select ud.device_user_name\n" +
                    ",ud.user_device_measure_period\n" +
                    ",ud.user_device_date_from\n" +
                    ",ud.device_units\n" +
                    ",ud.mqtt_topic_write\n" +
                    ",concat(concat(ser.server_ip,':'),ser.server_port) mqqtt\n" +
                    "from user_device ud\n" +
                    "left join mqtt_servers ser on ser.server_id = ud.mqqt_server_id\n" +
                    "where ud.user_device_id = ?";

            PreparedStatement DetectorDataStmt = Con.prepareStatement(DataSql);
            DetectorDataStmt.setInt(1,iUserDeviceId);

            ResultSet DetectorDataRs = DetectorDataStmt.executeQuery();

            while (DetectorDataRs.next()) {
                NameTextField.setValue(DetectorDataRs.getString(1));
                PeriodMeasureSelect.select(DetectorDataRs.getString(2));
                DetectorAddDate.setValue(df.format(new Date(DetectorDataRs.getTimestamp(3).getTime())));
                UnitsTextField.setValue(DetectorDataRs.getString(4));
                InTopicNameField.setValue(DetectorDataRs.getString(5));
                MqttServerSelect.select(DetectorDataRs.getString(6));
            }


            Con.close();

        } catch (SQLException se3) {
            //Handle errors for JDBC
            se3.printStackTrace();
        } catch (Exception e13) {
            //Handle errors for Class.forName
            e13.printStackTrace();
        }
    }

    public void getMqttServerData(){

        try {
            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            String DataSql = "select concat(concat(s.server_ip,':'),s.server_port)\n" +
                    "from mqtt_servers s";

            PreparedStatement MqttDataStmt = Con.prepareStatement(DataSql);

            ResultSet MqttDataRs = MqttDataStmt.executeQuery();

            while (MqttDataRs.next()) {
                MqttServerSelect.addItem(MqttDataRs.getString(1));
            }


            Con.close();

        } catch (SQLException se3) {
            //Handle errors for JDBC
            se3.printStackTrace();
        } catch (Exception e13) {
            //Handle errors for Class.forName
            e13.printStackTrace();
        }
    }
}
