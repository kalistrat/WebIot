package com.vaadin;

import com.vaadin.data.Property;
import com.vaadin.data.util.converter.Converter;
import com.vaadin.icons.VaadinIcons;
import com.vaadin.shared.ui.calendar.CalendarClientRpc;
import com.vaadin.shared.ui.datefield.Resolution;
import com.vaadin.shared.ui.label.ContentMode;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created by kalistrat on 24.05.2017.
 */
public class tRegistrationFormLayout extends VerticalLayout {

    TextField LoginField;
    //TextField NameTextField;
    PasswordField PassWordField;
    PasswordField ConfirmPassWordField;
    TextField PhoneTextField;
    TextField MailTextField;
    TextField PostCodeField;
    Button SendMailButton;
    Button ClearFormButton;
    NativeSelect SubjectTypeSelect;

    //For physical persons
    TextField FirstNameTextField;
    TextField SecondNameTextField;
    TextField MiddleNameTextField;
    DateField BirthDateField;

    //For juridical persons
    TextField SubjectNameTextField;
    TextField SubjectAddressTextField;
    TextField SubjectInnTextField;
    TextField SubjectKppField;

    FormLayout PersonalForm;


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
                //NameTextField.setValue(null);
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

        SubjectTypeSelect = new NativeSelect("Тип субъекта :");
        SubjectTypeSelect.addItem("физическое лицо");
        SubjectTypeSelect.addItem("юридическое лицо");
        SubjectTypeSelect.setNullSelectionAllowed(false);
        SubjectTypeSelect.select("физическое лицо");

        SubjectTypeSelect.addValueChangeListener(new Property.ValueChangeListener() {
            @Override
            public void valueChange(Property.ValueChangeEvent valueChangeEvent) {
                String SelectedValue = (String) valueChangeEvent.getProperty().getValue();
                //System.out.println("SubjectTypeSelect SelectedValue : " + SelectedValue);

                if (SelectedValue.equals("юридическое лицо")) {

                    PersonalForm.removeComponent(FirstNameTextField);
                    PersonalForm.removeComponent(SecondNameTextField);
                    PersonalForm.removeComponent(MiddleNameTextField);
                    PersonalForm.removeComponent(BirthDateField);

                    SubjectNameTextField = new TextField("Наименование организации :");
                    SubjectNameTextField.setNullRepresentation("");
                    SubjectNameTextField.setInputPrompt("От 5 до 150 символов (ООО Контакт)");

                    SubjectAddressTextField = new TextField("Адрес организации :");
                    SubjectAddressTextField.setNullRepresentation("");
                    SubjectAddressTextField.setInputPrompt("От 5 до 150 символов (г. Москва ул. Косыгина д.19)");

                    SubjectInnTextField = new TextField("Инн организации :");
                    SubjectInnTextField.setNullRepresentation("");
                    SubjectInnTextField.setInputPrompt("Строго 10 цифр (7714698320)");

                    SubjectKppField = new TextField("Кпп организации :");
                    SubjectKppField.setNullRepresentation("");
                    SubjectKppField.setInputPrompt("Строго 9 цифр (773301001)");

                    PersonalForm.addComponent(SubjectNameTextField);
                    PersonalForm.addComponent(SubjectAddressTextField);
                    PersonalForm.addComponent(SubjectInnTextField);
                    PersonalForm.addComponent(SubjectKppField);

                } else {

                    PersonalForm.removeComponent(SubjectNameTextField);
                    PersonalForm.removeComponent(SubjectAddressTextField);
                    PersonalForm.removeComponent(SubjectInnTextField);
                    PersonalForm.removeComponent(SubjectKppField);

                    PersonalForm.removeComponent(FirstNameTextField);
                    PersonalForm.removeComponent(SecondNameTextField);
                    PersonalForm.removeComponent(MiddleNameTextField);
                    PersonalForm.removeComponent(BirthDateField);

                    FirstNameTextField = new TextField("Имя :");
                    FirstNameTextField.setNullRepresentation("");
                    FirstNameTextField.setInputPrompt("Виктор");

                    SecondNameTextField = new TextField("Фамилия :");
                    SecondNameTextField.setNullRepresentation("");
                    SecondNameTextField.setInputPrompt("Глушков");

                    MiddleNameTextField = new TextField("Отчество :");
                    MiddleNameTextField.setNullRepresentation("");
                    MiddleNameTextField.setInputPrompt("Михайлович");

                    BirthDateField = new DateField("Дата рождения: "){
                        @Override
                        protected Date handleUnparsableDateString(String dateString)
                                throws Converter.ConversionException {
                            throw new Converter.ConversionException("Формат даты неверен. Используйте dd.MM.yyyy");
                        }
                    };
                    BirthDateField.setResolution(Resolution.DAY);
                    BirthDateField.setDateFormat("dd.MM.yyyy");
                    BirthDateField.setImmediate(true);

                    PersonalForm.addComponent(FirstNameTextField);
                    PersonalForm.addComponent(SecondNameTextField);
                    PersonalForm.addComponent(MiddleNameTextField);
                    PersonalForm.addComponent(BirthDateField);

                }
            }
        });

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

        //NameTextField = new TextField("Имя пользователя:");
        //NameTextField.setIcon(VaadinIcons.CLIPBOARD_USER);
        //NameTextField.setNullRepresentation("");
        //NameTextField.setInputPrompt("ФИО от 5 до 150 символов (Глушков Виктор Михайлович)");

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

        PostCodeField = new TextField("Почтовый индекс :");
        //PostCodeField.setIcon(VaadinIcons.ENVELOPE);
        PostCodeField.setNullRepresentation("");
        PostCodeField.setInputPrompt("6 цифр (119334)");

//        TextField FirstNameTextField;
//        TextField SecondNameTextField;
//        TextField MiddleNameTextField;
//        DateField BirthDateField;

        FirstNameTextField = new TextField("Имя :");
        FirstNameTextField.setNullRepresentation("");
        FirstNameTextField.setInputPrompt("Виктор");

        SecondNameTextField = new TextField("Фамилия :");
        SecondNameTextField.setNullRepresentation("");
        SecondNameTextField.setInputPrompt("Глушков");

        MiddleNameTextField = new TextField("Отчество :");
        MiddleNameTextField.setNullRepresentation("");
        MiddleNameTextField.setInputPrompt("Михайлович");

        BirthDateField = new DateField("Дата рождения: "){
            @Override
            protected Date handleUnparsableDateString(String dateString)
                    throws Converter.ConversionException {
                throw new Converter.ConversionException("Формат даты неверен. Используйте dd.MM.yyyy");
            }
        };
        BirthDateField.setResolution(Resolution.DAY);
        BirthDateField.setImmediate(true);
        BirthDateField.setDateFormat("dd.MM.yyyy");


        PersonalForm = new FormLayout(
                LoginField
                , PassWordField
                , ConfirmPassWordField
                , PhoneTextField
                , MailTextField
                , PostCodeField
                , SubjectTypeSelect
                , FirstNameTextField
                , SecondNameTextField
                , MiddleNameTextField
                , BirthDateField
        );

        PersonalForm.addStyleName(ValoTheme.FORMLAYOUT_LIGHT);
        PersonalForm.addStyleName("FormFont");
        PersonalForm.setMargin(false);
        PersonalForm.setWidth("100%");
        PersonalForm.setHeightUndefined();

        VerticalLayout FormLayout = new VerticalLayout(
                PersonalForm
                ,new tCaptchaLayout()
        );
        FormLayout.addStyleName(ValoTheme.LAYOUT_CARD);
        FormLayout.setWidth("900px");
        FormLayout.setHeightUndefined();
        FormLayout.setComponentAlignment(PersonalForm,Alignment.MIDDLE_CENTER);


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
