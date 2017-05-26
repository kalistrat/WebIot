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
 * Created by kalistrat on 26.05.2017.
 */
public class tActuatorDataFormLayout extends VerticalLayout {

    Button SaveButton;
    Button EditButton;
    int iUserDeviceId;

    TextField NameTextField;
    TextField DetectorAddDate;
    TextField InTopicNameField;
    TextField OutTopicNameField;
    NativeSelect MqttServerSelect;

    public tActuatorDataFormLayout(int eUserDeviceId) {

        iUserDeviceId = eUserDeviceId;

        Label Header = new Label();
        Header.setContentMode(ContentMode.HTML);
        Header.setValue(VaadinIcons.FORM.getHtml() + "  " + "Параметры исполнительного устройства");
        Header.addStyleName(ValoTheme.LABEL_COLORED);
        Header.addStyleName(ValoTheme.LABEL_SMALL);

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

            }
        });


        HorizontalLayout FormHeaderButtons = new HorizontalLayout(
                EditButton
                ,SaveButton
        );
        FormHeaderButtons.setSpacing(true);
        FormHeaderButtons.setSizeUndefined();

        HorizontalLayout FormHeaderLayout = new HorizontalLayout(
                Header
                , FormHeaderButtons
        );
        FormHeaderLayout.setWidth("100%");
        FormHeaderLayout.setHeightUndefined();
        FormHeaderLayout.setComponentAlignment(Header, Alignment.MIDDLE_LEFT);
        FormHeaderLayout.setComponentAlignment(FormHeaderButtons, Alignment.MIDDLE_RIGHT);

        NameTextField = new TextField("Наименование устройства :");
        NameTextField.setEnabled(false);
        DetectorAddDate = new TextField("Дата добавления устройства :");
        DetectorAddDate.setEnabled(false);
        InTopicNameField = new TextField("mqtt-топик для записи :");
        InTopicNameField.setEnabled(false);
        OutTopicNameField = new TextField("mqtt-топик для чтения :");
        OutTopicNameField.setEnabled(false);
        MqttServerSelect = new NativeSelect("mqtt-сервер :");
        MqttServerSelect.setNullSelectionAllowed(false);
        MqttServerSelect.setEnabled(false);
        tUsefulFuctions.getMqttServerData(MqttServerSelect);
        setActuatorParameters();


        FormLayout ActuatorForm = new FormLayout(
                NameTextField
                , DetectorAddDate
                , InTopicNameField
                , OutTopicNameField
                , MqttServerSelect
        );

        ActuatorForm.addStyleName(ValoTheme.FORMLAYOUT_LIGHT);
        ActuatorForm.addStyleName("FormFont");
        ActuatorForm.setMargin(false);

        VerticalLayout ActuatorFormLayout = new VerticalLayout(
                ActuatorForm
        );
        ActuatorFormLayout.addStyleName(ValoTheme.LAYOUT_CARD);
        ActuatorFormLayout.setWidth("100%");
        ActuatorFormLayout.setHeightUndefined();

        VerticalLayout ContentLayout = new VerticalLayout(
                FormHeaderLayout
                , ActuatorFormLayout
        );
        ContentLayout.setSpacing(true);
        ContentLayout.setWidth("100%");
        ContentLayout.setHeightUndefined();

        this.addComponent(ContentLayout);
    }

    public void setActuatorParameters(){

        DateFormat df = new SimpleDateFormat("dd.MM.yyyy");

        try {
            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            String DataSql = "select ud.device_user_name\n" +
                    ",ud.user_device_date_from\n" +
                    ",ud.mqtt_topic_write\n" +
                    ",ud.mqtt_topic_read\n" +
                    ",concat(concat(ser.server_ip,':'),ser.server_port) mqqtt\n" +
                    "from user_device ud\n" +
                    "join mqtt_servers ser on ser.server_id=ud.mqqt_server_id\n" +
                    "where ud.user_device_id = ?";

            PreparedStatement DataStmt = Con.prepareStatement(DataSql);
            DataStmt.setInt(1,iUserDeviceId);

            ResultSet DataRs = DataStmt.executeQuery();

            while (DataRs.next()) {
                NameTextField.setValue(DataRs.getString(1));
                if (DataRs.getTimestamp(2) != null) {
                    DetectorAddDate.setValue(df.format(new Date(DataRs.getTimestamp(2).getTime())));
                } else {
                    DetectorAddDate.setValue("");
                }
                InTopicNameField.setValue(DataRs.getString(3));
                OutTopicNameField.setValue(DataRs.getString(4));
                MqttServerSelect.select(DataRs.getString(5));

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
