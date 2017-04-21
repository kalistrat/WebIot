package com.vaadin;

import com.vaadin.navigator.View;
import com.vaadin.navigator.ViewChangeListener;
import com.vaadin.server.FontAwesome;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;
import org.vaadin.teemu.VaadinIcons;

/**
 * Created by kalistrat on 14.12.2016.
 */
public class tRegistrationVeiw extends CustomComponent implements View {

    public static final String NAME = "Registration";

    public tRegistrationVeiw(){
    }

    public void enter(ViewChangeListener.ViewChangeEvent event) {

        VerticalLayout tRegistrationVeiwContent = new VerticalLayout();
        tRegistrationVeiwContent.setSizeFull();
        VerticalLayout RegisrationSection = new VerticalLayout();
        VerticalLayout TopEmptySection = new VerticalLayout();
        TopEmptySection.setSizeFull();
        TopEmptySection.setHeight("50px");

        Button ReturnButton = new Button("Вернуться", new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent event) {
                getUI().getNavigator().navigateTo(tLoginView.NAME);
            }

        });
        ReturnButton.addStyleName(ValoTheme.BUTTON_LINK);

        TopEmptySection.addComponent(ReturnButton);
        TopEmptySection.setComponentAlignment(ReturnButton,Alignment.MIDDLE_RIGHT);

        //TopEmptySection.setHeight("50%");

        //Panel RegPanel = new Panel("Регистрационные данные");

        RegisrationSection.setCaption("Регистрационные данные");
        RegisrationSection.setSizeFull();
        RegisrationSection.setMargin(true);
        RegisrationSection.setSpacing(true);
        RegisrationSection.setWidth("40%");
        RegisrationSection.setIcon(VaadinIcons.USER_CARD);
        //RegisrationSection.setHeight("70%");
        RegisrationSection.addStyleName(ValoTheme.LAYOUT_CARD);

        TextField MailField = new TextField("Адрес электронной почты:");
        MailField.setIcon(FontAwesome.ENVELOPE);
        MailField.setWidth("85%");

        TextField LoginField = new TextField("Логин:");
        LoginField.setIcon(FontAwesome.USER);
        TextField NameField = new TextField("Имя:");
        NameField.setIcon(VaadinIcons.CLIPBOARD_USER);
        PasswordField PassField = new PasswordField("Пароль:");
        PassField.setIcon(FontAwesome.KEY);

        LoginField.setWidth("85%");
        NameField.setWidth("85%");
        PassField.setWidth("85%");


        Button RegButton = new Button("Отправить заявку", new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent event) {
            }
        });
        RegButton.setIcon(FontAwesome.SEND);

        Button ClearButton = new Button("Очистить", new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent event) {
                LoginField.setValue("");
                MailField.setValue("");
                NameField.setValue("");
                PassField.setValue("");
            }
        });

        RegisrationSection.addComponent(LoginField);
        RegisrationSection.addComponent(NameField);
        RegisrationSection.addComponent(PassField);
        RegisrationSection.addComponent(MailField);
        RegisrationSection.setComponentAlignment(LoginField,Alignment.MIDDLE_CENTER);
        RegisrationSection.setComponentAlignment(NameField,Alignment.MIDDLE_CENTER);
        RegisrationSection.setComponentAlignment(PassField,Alignment.MIDDLE_CENTER);
        RegisrationSection.setComponentAlignment(MailField,Alignment.MIDDLE_CENTER);



        HorizontalLayout ForgetLayout = new HorizontalLayout();

        HorizontalLayout ButtonsLayout = new HorizontalLayout(RegButton,ClearButton);
        //ButtonsLayout.setMargin(true);
        ButtonsLayout.setSpacing(true);
        //ButtonsLayout.setWidth("150%");

        //ButtonsLayout.addComponent(RegButton);
        //ButtonsLayout.addComponent(ClearButton);

        RegisrationSection.addComponent(ForgetLayout);
        RegisrationSection.addComponent(ButtonsLayout);
        RegisrationSection.setComponentAlignment(ButtonsLayout,Alignment.MIDDLE_CENTER);

        tRegistrationVeiwContent.addComponent(TopEmptySection);
        //tRegistrationVeiwContent.setExpandRatio(RegisrationSection,1f);
        tRegistrationVeiwContent.addComponent(RegisrationSection);
        //tRegistrationVeiwContent.setExpandRatio(TopEmptySection,2);
        tRegistrationVeiwContent.setComponentAlignment(RegisrationSection,Alignment.MIDDLE_CENTER);


        setCompositionRoot(tRegistrationVeiwContent);
    }
}
