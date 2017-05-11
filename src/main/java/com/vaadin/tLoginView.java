package com.vaadin;

import com.vaadin.navigator.View;
import com.vaadin.navigator.ViewChangeListener;
import com.vaadin.server.FontAwesome;
import com.vaadin.server.Page;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;
import org.vaadin.teemu.VaadinIcons;

import java.sql.*;

/**
 * Created by SemenovNA on 02.08.2016.
 */
public class tLoginView extends CustomComponent implements View {

    public static final String NAME = "Login";

    //Кнопки
    Button LogOnButton = new Button("Войти");
    Button RemindPassButton = new Button("Напомнить пароль");
    Button RegButton = new Button("Регистрация");

    //Метка
    Label LogInLabel = new Label("Авторизация");

    //Поля
    TextField LogInField = new TextField("Имя пользователя");
    PasswordField PassField = new PasswordField("Пароль");


    public tLoginView(){
        setSizeFull();
        VerticalLayout LoginViewLayOut = new VerticalLayout();


        VerticalLayout LoginBox = new VerticalLayout();
        LoginBox.setSpacing(true);

        LogInField.setWidth("320px");
        LogInField.setIcon(FontAwesome.USER);
        PassField.setWidth("320px");
        PassField.setIcon(FontAwesome.KEY);


        LogInLabel.setSizeUndefined();
        LoginBox.addComponent(LogInLabel);

        LoginBox.addComponent(LogInField);
        LoginBox.addComponent(PassField);

        LoginBox.setComponentAlignment(LogInLabel,Alignment.MIDDLE_CENTER);
        LoginBox.setComponentAlignment(LogInField,Alignment.MIDDLE_LEFT);
        LoginBox.setComponentAlignment(PassField,Alignment.MIDDLE_LEFT);

        HorizontalLayout ButtonsBox = new HorizontalLayout();
        ButtonsBox.setSpacing(true);
        ButtonsBox.setSizeUndefined();

        LogOnButton.setSizeUndefined();
        LogOnButton.setIcon(FontAwesome.SIGN_IN);

        RemindPassButton.setSizeUndefined();
        RemindPassButton.setIcon(FontAwesome.QUESTION);

        RemindPassButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                //tRemindWindow RemWin = new tRemindWindow();
                UI.getCurrent().addWindow(new tRemindWindow());
            }
        });

        LogOnButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                String username = LogInField.getValue();
                String password = PassField.getValue();
                Integer IsPlayerExists = 0;

                try {
                    Class.forName(tUsefulFuctions.JDBC_DRIVER);
                    Connection conn = DriverManager.getConnection(
                            tUsefulFuctions.DB_URL
                            ,tUsefulFuctions.USER
                            ,tUsefulFuctions.PASS
                    );

                    CallableStatement CheckUserStmt = conn.prepareCall("{? = call f_is_user_exists(?, ?)}");
                    CheckUserStmt.registerOutParameter (1, Types.INTEGER);
                    CheckUserStmt.setString(2, username);
                    CheckUserStmt.setString(3, password);
                    CheckUserStmt.execute();
                    IsPlayerExists = CheckUserStmt.getInt(1);

                    conn.close();
                } catch(SQLException SQLe){
                    //Handle errors for JDBC
                    SQLe.printStackTrace();
                }catch(Exception e1){
                    //Handle errors for Class.forName
                    e1.printStackTrace();
                }

                if (IsPlayerExists.equals(1)) {

                    // Store the current user in the service session
                    getSession().setAttribute("user", username);

                    // Navigate to main view
                    getUI().getNavigator().navigateTo(tMainView.NAME);//

                } else {

                    PassField.setValue("");
                    LogInField.setValue("");
                    PassField.focus();
                    Notification PassWrongNotication = new Notification("Несуществующее сочетание логина и пароля","");
                    PassWrongNotication.show(Page.getCurrent());

                }
            }
        });

        ButtonsBox.addComponent(LogOnButton);
        ButtonsBox.addComponent(RemindPassButton);
        ButtonsBox.setComponentAlignment(LogOnButton,Alignment.BOTTOM_LEFT);
        ButtonsBox.setComponentAlignment(RemindPassButton,Alignment.BOTTOM_RIGHT);

        LoginBox.addComponent(ButtonsBox);
        LoginBox.setComponentAlignment(ButtonsBox,Alignment.MIDDLE_LEFT);
        LoginBox.setSizeUndefined();

        RegButton.addStyleName(ValoTheme.BUTTON_LINK);
        RegButton.setIcon(FontAwesome.USER_PLUS);

        RegButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                    // Navigate to main view
                    getUI().getNavigator().navigateTo(tRegistrationVeiw.NAME);//
            }
        });

        LoginViewLayOut.addComponent(RegButton);
        LoginViewLayOut.setComponentAlignment(RegButton,Alignment.TOP_RIGHT);

        LoginViewLayOut.addComponent(LoginBox);
        LoginViewLayOut.setComponentAlignment(LoginBox,Alignment.MIDDLE_CENTER);

        LoginViewLayOut.setSizeFull();

        LoginViewLayOut.setExpandRatio(LoginBox,2);



        setCompositionRoot(LoginViewLayOut);

    }

    public void enter(ViewChangeListener.ViewChangeEvent event) {
        // focus the username field when user arrives to the login view
        LogInField.focus();
    }

}
