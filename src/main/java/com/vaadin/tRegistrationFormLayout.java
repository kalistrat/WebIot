package com.vaadin;

import com.vaadin.icons.VaadinIcons;
import com.vaadin.shared.ui.calendar.CalendarClientRpc;
import com.vaadin.shared.ui.label.ContentMode;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

/**
 * Created by kalistrat on 24.05.2017.
 */
public class tRegistrationFormLayout extends VerticalLayout {

    TextField LoginField;
    TextField NameTextField;
    PasswordField PassWordField;
    PasswordField ConfirmPassWordField;
    TextField PhoneTextField;
    TextField MailTextField;
    Button SendMailButton;
    Button ClearFormButton;

    public tRegistrationFormLayout() {



        Label Header = new Label();
        Header.setContentMode(ContentMode.HTML);
        Header.setValue(VaadinIcons.USER_CARD.getHtml() + "  " + "Регистрационные данные пользователя");
        Header.addStyleName(ValoTheme.LABEL_COLORED);
        Header.addStyleName(ValoTheme.LABEL_SMALL);

        SendMailButton = new Button("Отправить заявку на доступ");
        SendMailButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);
        SendMailButton.addStyleName(ValoTheme.BUTTON_SMALL);
        SendMailButton.setIcon(VaadinIcons.PAPERPLANE);

        ClearFormButton = new Button("Очистить форму");
        ClearFormButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);
        ClearFormButton.addStyleName(ValoTheme.BUTTON_SMALL);
        ClearFormButton.setIcon(VaadinIcons.ERASER);

        ClearFormButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                LoginField.setValue(null);
                NameTextField.setValue(null);
                PassWordField.setValue("");
                ConfirmPassWordField.setValue("");
                PhoneTextField.setValue(null);
                MailTextField.setValue(null);
            }
        });

        HorizontalLayout FormHeaderButtons = new HorizontalLayout(
                SendMailButton
                ,ClearFormButton
        );
        FormHeaderButtons.setSpacing(true);
        FormHeaderButtons.setSizeUndefined();


        HorizontalLayout FormHeaderLayout = new HorizontalLayout(
                Header
                ,FormHeaderButtons
        );
        FormHeaderLayout.setWidth("100%");
        FormHeaderLayout.setHeightUndefined();
        FormHeaderLayout.setComponentAlignment(Header, Alignment.MIDDLE_LEFT);
        FormHeaderLayout.setComponentAlignment(FormHeaderButtons, Alignment.MIDDLE_RIGHT);


        LoginField = new TextField("Логин :");
        LoginField.setIcon(VaadinIcons.USER);
        LoginField.setNullRepresentation("");
        LoginField.setInputPrompt("Мнемоническое имя, содержащее латиницу и цифры от 7 до 50 символов (GlushkovVM1923)");

        NameTextField = new TextField("Имя пользователя:");
        NameTextField.setIcon(VaadinIcons.CLIPBOARD_USER);
        NameTextField.setNullRepresentation("");
        NameTextField.setInputPrompt("ФИО от 5 до 150 символов (Глушков Виктор Михайлович)");

        PassWordField = new PasswordField("Пароль :");
        PassWordField.setIcon(VaadinIcons.KEY);
        ConfirmPassWordField = new PasswordField("Подтверждение пароля :");
        ConfirmPassWordField.setIcon(VaadinIcons.KEY_O);

        PhoneTextField = new TextField("Номер телефона :");
        PhoneTextField.setIcon(VaadinIcons.PHONE);
        PhoneTextField.setNullRepresentation("");
        PhoneTextField.setInputPrompt("Номер телефона 12 символов (+79160000000)");

        MailTextField = new TextField("Адрес электронной почты :");
        MailTextField.setIcon(VaadinIcons.ENVELOPE);
        MailTextField.setNullRepresentation("");
        MailTextField.setInputPrompt("Имя почтового ящика с доменом до 150 символов (GlushkovVM@ussras.ru)");

        FormLayout Form = new FormLayout(
                LoginField
                , NameTextField
                , PassWordField
                , ConfirmPassWordField
                , PhoneTextField
                , MailTextField
        );

        Form.addStyleName(ValoTheme.FORMLAYOUT_LIGHT);
        Form.addStyleName("FormFont");
        Form.setMargin(false);
        Form.setWidth("100%");
        Form.setHeightUndefined();

        VerticalLayout FormLayout = new VerticalLayout(
                Form
        );
        FormLayout.addStyleName(ValoTheme.LAYOUT_CARD);
        FormLayout.setWidth("900px");
        FormLayout.setHeightUndefined();
        FormLayout.setComponentAlignment(Form,Alignment.MIDDLE_CENTER);


        VerticalLayout ContentLayout = new VerticalLayout(
                FormHeaderLayout
                , FormLayout
        );
        ContentLayout.setSpacing(true);
        //ContentLayout.setWidth("100%");
        ContentLayout.setSizeUndefined();

        this.addComponent(ContentLayout);
    }
}
