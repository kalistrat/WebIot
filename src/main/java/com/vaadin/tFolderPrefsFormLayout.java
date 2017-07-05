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
 * Created by kalistrat on 05.07.2017.
 */
public class tFolderPrefsFormLayout extends VerticalLayout {

    Button SaveButton;
    Button EditButton;
    int iUserDeviceId;

    TextField NameTextField;
    TextField DetectorAddDate;
    TextField InTopicNameField;
    TextField OutTopicNameField;
    //NativeSelect MqttServerSelect;
    TextField MqttServerTextField;

    TextField DeviceLoginTextField;
    TextField DevicePassWordTextField;

    public tFolderPrefsFormLayout(int eUserDeviceId) {

        iUserDeviceId = eUserDeviceId;

        Label Header = new Label();
        Header.setContentMode(ContentMode.HTML);
        Header.setValue(VaadinIcons.FORM.getHtml() + "  " + "Параметры контроллера");
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

        NameTextField = new TextField("Наименование контроллера :");
        NameTextField.setEnabled(false);
        OutTopicNameField = new TextField("mqtt-топик для синхронизации времени :");
        OutTopicNameField.setEnabled(false);

        DeviceLoginTextField = new TextField("Логин контроллера :");
        DevicePassWordTextField = new TextField("Пароль контроллера :");
        MqttServerTextField = new TextField("mqtt-сервер :");
        DeviceLoginTextField.setEnabled(false);
        DevicePassWordTextField.setEnabled(false);
        MqttServerTextField.setEnabled(false);

        setControlerParameters();


        FormLayout ControlerForm = new FormLayout(
                NameTextField
                , OutTopicNameField
                , MqttServerTextField
                , DeviceLoginTextField
                , DevicePassWordTextField
        );

        ControlerForm.addStyleName(ValoTheme.FORMLAYOUT_LIGHT);
        ControlerForm.addStyleName("FormFont");
        ControlerForm.setMargin(false);

        VerticalLayout ControlerFormLayout = new VerticalLayout(
                ControlerForm
        );
        ControlerFormLayout.addStyleName(ValoTheme.LAYOUT_CARD);
        ControlerFormLayout.setWidth("100%");
        ControlerFormLayout.setHeightUndefined();

        VerticalLayout ContentLayout = new VerticalLayout(
                FormHeaderLayout
                , ControlerFormLayout
        );
        ContentLayout.setSpacing(true);
        ContentLayout.setWidth("100%");
        ContentLayout.setHeightUndefined();

        this.addComponent(ContentLayout);
    }

    public void setControlerParameters(){

        try {
            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            String DataSql = "";

            PreparedStatement DataStmt = Con.prepareStatement(DataSql);
            DataStmt.setInt(1,iUserDeviceId);

            ResultSet DataRs = DataStmt.executeQuery();

            while (DataRs.next()) {
                NameTextField.setValue(DataRs.getString(1));
                OutTopicNameField.setValue(DataRs.getString(4));
                MqttServerTextField.setValue("tcp://" + DataRs.getString(5));
                DeviceLoginTextField.setValue(DataRs.getString(6));
                DevicePassWordTextField.setValue(DataRs.getString(7));

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
