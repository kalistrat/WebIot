package com.vaadin;

import com.vaadin.data.Item;
import com.vaadin.data.util.converter.StringToIntegerConverter;
import com.vaadin.data.validator.IntegerRangeValidator;
import com.vaadin.icons.VaadinIcons;
import com.vaadin.server.FontAwesome;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

import java.sql.*;
import java.text.NumberFormat;
import java.util.Locale;

/**
 * Created by kalistrat on 15.05.2017.
 */
public class tAddFolderWindow extends Window {

    Button SaveButton;
    Button CancelButton;
    tTreeContentLayout iTreeContentLayout;
    int iLeafId;
    int iNewTreeId;
    int iNewLeafId;

    TextField NameTextField;
    TextField MqttServerTextField;
    TextField DeviceLoginTextField;
    TextField DevicePassWordTextField;
    TextField OutTopicNameField;
    NativeSelect TimeZoneSelect;
    TextField TimeSyncInterval;
    CheckBox SLLCheck;

    public tAddFolderWindow(int eLeafId
            ,tTreeContentLayout eParentContentLayout
    ){
        iLeafId = eLeafId;
        iTreeContentLayout = eParentContentLayout;

        iNewTreeId = 0;
        iNewLeafId = 0;

        this.setIcon(VaadinIcons.FOLDER_ADD);
        this.setCaption(" Добавление контроллера");

        SaveButton = new Button("Сохранить");

        SaveButton.setData(this);
        SaveButton.addStyleName(ValoTheme.BUTTON_SMALL);
        SaveButton.setIcon(FontAwesome.SAVE);

        SaveButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {

                String sErrorMessage = "";
                String sFieldValue = NameTextField.getValue();

                if (sFieldValue == null){
                    sErrorMessage = "Наименование контроллера не задано\n";
                }

                if (sFieldValue.equals("")){
                    sErrorMessage = "Наименование контроллера не задано\n";
                }

                if (sFieldValue.length() > 30){
                    sErrorMessage = "Длина наименования превышает 30 символов\n";
                }

                if (tUsefulFuctions.fIsLeafNameBusy(iTreeContentLayout.iUserLog,sFieldValue) > 0){
                    sErrorMessage = "Указанное наименование уже используется. Введите другое.\n";
                }

                if (!sErrorMessage.equals("")){
                    Notification.show("Ошибка сохранения:",
                            sErrorMessage,
                            Notification.Type.TRAY_NOTIFICATION);
                } else {


                    addSubFolder(iLeafId,sFieldValue,iTreeContentLayout.iUserLog);

                    if (iNewTreeId != 0) {

                        Item newItem = iTreeContentLayout.itTree.TreeContainer.addItem(iNewLeafId);
                        newItem.getItemProperty(1).setValue(iNewTreeId);
                        newItem.getItemProperty(2).setValue(iNewLeafId);
                        newItem.getItemProperty(3).setValue(iLeafId);
                        newItem.getItemProperty(4).setValue(sFieldValue);
                        newItem.getItemProperty(5).setValue("FOLDER");
                        newItem.getItemProperty(6).setValue(0);
                        newItem.getItemProperty(7).setValue(null);

                        iTreeContentLayout.itTree.TreeContainer.setParent(iNewLeafId, iLeafId);
                        iTreeContentLayout.itTree.setItemIcon(iNewLeafId, VaadinIcons.FOLDER);
                        iTreeContentLayout.tTreeContentLayoutRefresh(iLeafId,0);
                        iTreeContentLayout.itTree.expandItem(iLeafId);
                    }
                    Notification.show("Контроллер добавлен!",
                            null,
                            Notification.Type.TRAY_NOTIFICATION);
                    UI.getCurrent().removeWindow((tAddFolderWindow) clickEvent.getButton().getData());

                }


            }
        });

        CancelButton = new Button("Отменить");

        CancelButton.setData(this);
        CancelButton.addStyleName(ValoTheme.BUTTON_SMALL);
        CancelButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                UI.getCurrent().removeWindow((tAddFolderWindow) clickEvent.getButton().getData());
            }
        });

        HorizontalLayout ButtonsLayout = new HorizontalLayout(
                SaveButton
                ,CancelButton
        );

        ButtonsLayout.setSizeUndefined();
        ButtonsLayout.setSpacing(true);

        NameTextField = new TextField("Наименование контроллера :");
        NameTextField.addStyleName(ValoTheme.TEXTFIELD_SMALL);

        MqttServerTextField = new TextField("mqtt-сервер :");
        MqttServerTextField.addStyleName(ValoTheme.TEXTFIELD_SMALL);

        DeviceLoginTextField = new TextField("Логин контроллера :");
        DeviceLoginTextField.addStyleName(ValoTheme.TEXTFIELD_SMALL);

        DevicePassWordTextField = new TextField("Пароль контроллера :");
        DevicePassWordTextField.addStyleName(ValoTheme.TEXTFIELD_SMALL);

        OutTopicNameField = new TextField("mqtt-топик для синхронизации времени :");
        OutTopicNameField.addStyleName(ValoTheme.TEXTFIELD_SMALL);

        TimeZoneSelect = new NativeSelect("Часовой пояс контроллера :");
        TimeZoneSelect.setNullSelectionAllowed(false);
        tUsefulFuctions.setTimeZoneList(TimeZoneSelect);
        TimeZoneSelect.select("UTC+3");
        TimeSyncInterval = new TextField("Интервал синхронизации времени (в сутках) :");
        TimeSyncInterval.addStyleName(ValoTheme.TEXTFIELD_SMALL);
        StringToIntegerConverter plainIntegerConverter = new StringToIntegerConverter() {
            protected java.text.NumberFormat getFormat(Locale locale) {
                NumberFormat format = super.getFormat(locale);
                format.setGroupingUsed(false);
                return format;
            };
        };
        TimeSyncInterval.setConverter(plainIntegerConverter);
        TimeSyncInterval.addValidator(new IntegerRangeValidator("Значение может изменяться от 1 до 365", 1, 365));
        TimeSyncInterval.setConversionError("Введённое значение не является целочисленным");
        TimeSyncInterval.setNullRepresentation("");
        TimeSyncInterval.setValue("");

        SLLCheck = new CheckBox("шифрование трафика (SSL)");
        SLLCheck.addStyleName(ValoTheme.CHECKBOX_SMALL);


        FormLayout ContParamLayout = new FormLayout(
                NameTextField
                , MqttServerTextField
                , DeviceLoginTextField
                , DevicePassWordTextField
                , OutTopicNameField
                , TimeZoneSelect
                , TimeSyncInterval
                , SLLCheck
        );
        ContParamLayout.addStyleName(ValoTheme.FORMLAYOUT_LIGHT);
        ContParamLayout.setSizeUndefined();
        ContParamLayout.setMargin(false);

        VerticalLayout MessageLayout = new VerticalLayout(
                ContParamLayout
        );

        MessageLayout.setSpacing(true);
        MessageLayout.setSizeUndefined();
        MessageLayout.setMargin(true);
        MessageLayout.setComponentAlignment(ContParamLayout, Alignment.MIDDLE_CENTER);
        MessageLayout.addStyleName(ValoTheme.LAYOUT_CARD);

        VerticalLayout WindowContentLayout = new VerticalLayout(
                MessageLayout
                ,ButtonsLayout
        );
        WindowContentLayout.setSizeUndefined();
        WindowContentLayout.setSpacing(true);
        WindowContentLayout.setMargin(true);
        WindowContentLayout.setComponentAlignment(ButtonsLayout, Alignment.BOTTOM_CENTER);

        this.setContent(WindowContentLayout);
        this.setSizeUndefined();
        this.setModal(true);
    }

    public void addSubFolder(
            int qParentLeafId
            ,String qSubFolderName
            ,String qUserLog
    ){
        try {

            Class.forName(tUsefulFuctions.JDBC_DRIVER);
            Connection Con = DriverManager.getConnection(
                    tUsefulFuctions.DB_URL
                    , tUsefulFuctions.USER
                    , tUsefulFuctions.PASS
            );

            CallableStatement addFolderStmt = Con.prepareCall("{call p_add_subfolder(?, ?, ?, ?, ?)}");
            addFolderStmt.setInt(1, qParentLeafId);
            addFolderStmt.setString(2, qSubFolderName);
            addFolderStmt.setString(3, qUserLog);
            addFolderStmt.registerOutParameter(4, Types.INTEGER);
            addFolderStmt.registerOutParameter(5, Types.INTEGER);
            addFolderStmt.execute();

            iNewTreeId = addFolderStmt.getInt(4);
            iNewLeafId = addFolderStmt.getInt(5);

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
