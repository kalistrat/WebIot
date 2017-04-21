package com.vaadin;

import com.vaadin.data.Property;
import com.vaadin.data.util.converter.Converter;
import com.vaadin.server.FontAwesome;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;
import org.vaadin.teemu.VaadinIcons;

import java.sql.*;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

/**
 * Created by kalistrat on 14.02.2017.
 */
public class tDetectorScheduleLayout extends VerticalLayout {

    String UserDeviceMode;
    Date UserDeviceDateFrom;
    String UserDevicePeriod;
    String UserDeviceName;

    OptionGroup ModeSelect;
    PopupDateField FirstDateSerially;
    NativeSelect SerialSelect;
    Button EditButton;
    Button SaveButton;

    static final private String JDBC_DRIVER = "com.mysql.jdbc.Driver";
    static final private String DB_URL = "jdbc:mysql://localhost/things";
    static final private String USER = "kalistrat";
    static final private String PASS = "045813";

    int tUserDeviceId;

    public tDetectorScheduleLayout(int iUserDeviceId){

        List<String> SMods = Arrays.asList(new String[] {
                "Периодическое измерение"
                , "Однократное измерение"}
        );

        List<String> SPeriodCods = Arrays.asList(new String[] {
                        "ежеминутно"
                        , "ежечасно"
                        , "ежесуточно"
                        , "еженедельно"
                        , "ежемесячно"
                        , "ежегодно"

        }
        );

        this.GetDeviceData(iUserDeviceId);
        tUserDeviceId = iUserDeviceId;

        ModeSelect = new OptionGroup("Режим измерений",SMods);

        ModeSelect.setNullSelectionAllowed(false);
        ModeSelect.select(UserDeviceMode);
        ModeSelect.setImmediate(true);
        ModeSelect.setEnabled(false);

        ModeSelect.addValueChangeListener(new Property.ValueChangeListener() {
            @Override
            public void valueChange(Property.ValueChangeEvent e) {
//                Notification.show("Value changed:",
//                        String.valueOf(e.getProperty().getValue()),
//                        Notification.Type.TRAY_NOTIFICATION);
                if (ModeSelect.getValue().equals("Периодическое измерение")) {
                    SerialSelect.setEnabled(true);
                    SerialSelect.setNullSelectionAllowed(false);
                    SerialSelect.setValue("ежечасно");
                } else {
                    SerialSelect.setEnabled(false);
                    SerialSelect.setNullSelectionAllowed(true);
                    SerialSelect.setValue(null);
                }
            }
        });

        ModeSelect.addStyleName(ValoTheme.OPTIONGROUP_SMALL);



        FirstDateSerially = new PopupDateField("Дата начала снятия показаний"){
            @Override
            protected Date handleUnparsableDateString(String dateString)
                    throws Converter.ConversionException {
                // Have a notification for the error
//                Notification.show("Ошибка ввода:",
//                        "Дата должна быть в формате: ДД.ММ.ГГ ЧЧ:МИ:СС",
//                        Notification.Type.TRAY_NOTIFICATION);

                // A failure must always also throw an exception
                throw new Converter.ConversionException("Формат даты неверен. Используйте dd.mm.yy h24:mi:ss");
            }
        };

        FirstDateSerially.setValue(UserDeviceDateFrom);
        FirstDateSerially.addStyleName(ValoTheme.DATEFIELD_SMALL);
        FirstDateSerially.setEnabled(false);
        FirstDateSerially.setResolution(FirstDateSerially.RESOLUTION_SEC);
        FirstDateSerially.setImmediate(true);

        FirstDateSerially.addValueChangeListener(new Property.ValueChangeListener() {
            @Override
            public void valueChange(Property.ValueChangeEvent e) {
                    //System.out.println(e.getProperty().getValue());
                if (e.getProperty().getValue()!=null) {
                    Date Sdate = (Date) e.getProperty().getValue();
                    if (Sdate.before(new Date())) {
                        Notification.show("Недопустимая дата:",
                                "Нельзя провести измерение ранее текущего момента",
                                Notification.Type.TRAY_NOTIFICATION);
                    }
                }
            }
        });


        SerialSelect = new NativeSelect("Период снятия показаний",SPeriodCods);
        //SerialSelect.setNullSelectionAllowed(false);
        SerialSelect.setValue(UserDevicePeriod);
        SerialSelect.setImmediate(true);
        SerialSelect.setEnabled(false);


//        SerialSelect.addValueChangeListener(new Property.ValueChangeListener() {
//                 @Override
//                 public void valueChange(Property.ValueChangeEvent e) {
//                     if (ModeSelect.getValue().equals("Периодическое измерение")) {
//                         SerialSelect.setEnabled(true);
//                     } else {
//                         SerialSelect.setEnabled(false);
//                     }
//
//                 }
//             }
//        );

        EditButton = new Button("Редактировать");
        EditButton.addStyleName(ValoTheme.BUTTON_SMALL);
        EditButton.setIcon(VaadinIcons.PENCIL);

        EditButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(final Button.ClickEvent event) {
                ModeSelect.setEnabled(true);
                FirstDateSerially.setEnabled(true);
                SaveButton.setEnabled(true);
                if (ModeSelect.getValue().equals("Периодическое измерение")) {
                    SerialSelect.setEnabled(true);
                    SerialSelect.setNullSelectionAllowed(false);
                    SerialSelect.setValue("ежечасно");
                } else {
                    SerialSelect.setEnabled(false);
                    SerialSelect.setNullSelectionAllowed(true);
                    SerialSelect.setValue(null);
                }
                EditButton.setEnabled(false);

            }
        });



        SaveButton = new Button("Сохранить");
        SaveButton.addStyleName(ValoTheme.BUTTON_SMALL);
        SaveButton.setIcon(FontAwesome.SAVE);
        SaveButton.setEnabled(false);

        SaveButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(final Button.ClickEvent event) {

                Date Sdate = FirstDateSerially.getValue();
                if (Sdate.before(new Date())) {
                    Notification.show("Недопустимая дата:",
                            "Нельзя провести измерение ранее текущего момента",
                            Notification.Type.TRAY_NOTIFICATION);
                } else {
                    SerialSelect.setEnabled(false);
                    ModeSelect.setEnabled(false);
                    FirstDateSerially.setEnabled(false);
                    EditButton.setEnabled(true);
                    SaveButton.setEnabled(false);
                    UpdDeviceData(tUserDeviceId);
                }

            }
        });


        HorizontalLayout ContentLay = new HorizontalLayout();
        ContentLay.setSpacing(true);
        HorizontalLayout ButtonsLay = new HorizontalLayout(EditButton,SaveButton);
        ButtonsLay.setSpacing(true);

        VerticalLayout LeftBox = new VerticalLayout(
                ModeSelect
                ,ButtonsLay
        );
        LeftBox.setSpacing(true);
        LeftBox.setComponentAlignment(ButtonsLay,Alignment.MIDDLE_CENTER);
        Label EmptyLabel = new Label();
        EmptyLabel.addStyleName(ValoTheme.LABEL_TINY);

        VerticalLayout CentralBox = new VerticalLayout(
                SerialSelect
                //,EmptyLabel
                ,FirstDateSerially
        );
        CentralBox.setSpacing(true);

//        VerticalLayout RightBox1 = new VerticalLayout(
//                new Label()
//                ,EditButton
//                ,SaveButton
//        );
//        RightBox1.setSpacing(true);


        ContentLay.addComponent(LeftBox);
        ContentLay.addComponent(CentralBox);
        //ContentLay.addComponent(RightBox1);


        this.setCaption("Настройка работы устройства");
        this.setIcon(VaadinIcons.SLIDERS);
        this.addComponent(ContentLay);


    }

    public void GetDeviceData(int iUserDeviceId){

        this.UserDeviceName = null;
        this.UserDeviceMode = null;
        this.UserDevicePeriod = null;
        this.UserDeviceDateFrom = null;



        try {
            Class.forName(JDBC_DRIVER);
            Connection conn = DriverManager.getConnection(DB_URL,USER,PASS);

            CallableStatement DevicePrefsStmt = conn.prepareCall("{call p_get_user_device_perfs(?,?,?,?,?)}");
            DevicePrefsStmt.setInt(1, iUserDeviceId);
            DevicePrefsStmt.registerOutParameter (2, Types.VARCHAR);
            DevicePrefsStmt.registerOutParameter (3, Types.VARCHAR);
            DevicePrefsStmt.registerOutParameter (4, Types.VARCHAR);
            DevicePrefsStmt.registerOutParameter (5, Types.TIMESTAMP);
            DevicePrefsStmt.execute();

            this.UserDeviceName = DevicePrefsStmt.getString(2);
            this.UserDeviceMode = DevicePrefsStmt.getString(3);
            this.UserDevicePeriod = DevicePrefsStmt.getString(4);
            this.UserDeviceDateFrom = DevicePrefsStmt.getTimestamp(5);

//            System.out.println("UserDeviceName " + this.UserDeviceName);
//            System.out.println("UserDeviceMode " + this.UserDeviceMode);
//            System.out.println("UserDevicePeriod " + this.UserDevicePeriod);
//            System.out.println("UserDeviceDateFrom " + this.UserDeviceDateFrom);

            conn.close();
        } catch(SQLException SQLe){
            //Handle errors for JDBC
            SQLe.printStackTrace();
        }catch(Exception e1){
            //Handle errors for Class.forName
            e1.printStackTrace();

        }
    }

    public void UpdDeviceData(int iUserDeviceId){

        this.UserDeviceMode = (String) ModeSelect.getValue();
        this.UserDevicePeriod = (String) SerialSelect.getValue();
        this.UserDeviceDateFrom = FirstDateSerially.getValue();

        java.sql.Timestamp  sqlDateFrom = new java.sql.Timestamp (this.UserDeviceDateFrom.getTime());


        try {
            Class.forName(JDBC_DRIVER);
            Connection conn = DriverManager.getConnection(DB_URL,USER,PASS);

            CallableStatement DeviceUpdStmt = conn.prepareCall("{call p_upd_user_device_perfs(?,?,?,?)}");
            DeviceUpdStmt.setInt(1, iUserDeviceId);
            DeviceUpdStmt.setString(2, this.UserDeviceMode);
            DeviceUpdStmt.setString(3, this.UserDevicePeriod);
            DeviceUpdStmt.setTimestamp(4, sqlDateFrom);
            DeviceUpdStmt.execute();
            conn.close();
        } catch(SQLException SQLe){
            //Handle errors for JDBC
            SQLe.printStackTrace();
        }catch(Exception e1){
            //Handle errors for Class.forName
            e1.printStackTrace();

        }
    }

}
