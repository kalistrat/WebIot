package com.vaadin;

import com.vaadin.data.util.IndexedContainer;
import com.vaadin.icons.VaadinIcons;
import com.vaadin.server.FontAwesome;
import com.vaadin.shared.ui.label.ContentMode;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

/**
 * Created by kalistrat on 01.11.2017.
 */
public class tNotificationDetectorLayout extends VerticalLayout {
    Button AddButton;
    Button DeleteButton;
    Button SaveButton;

    Table iNotificationTable;
    IndexedContainer iNotificationContainer;
    int iUserDeviceId;
    tTreeContentLayout iParentContentLayout;

    public tNotificationDetectorLayout(
            int eUserDeviceId
            ,tTreeContentLayout eParentContentLayout
    ){

        iUserDeviceId = eUserDeviceId;
        iParentContentLayout = eParentContentLayout;

        Label Header = new Label();
        Header.setContentMode(ContentMode.HTML);
        Header.setValue(VaadinIcons.CALENDAR_ENVELOPE.getHtml() + "  " + "Перечень оповещений");
        Header.addStyleName(ValoTheme.LABEL_COLORED);
        Header.addStyleName(ValoTheme.LABEL_SMALL);

        SaveButton = new Button();
        SaveButton.setIcon(FontAwesome.SAVE);
        SaveButton.addStyleName(ValoTheme.BUTTON_SMALL);
        SaveButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);
        SaveButton.setEnabled(false);

        AddButton = new Button();
        AddButton.setIcon(VaadinIcons.PLUS);
        AddButton.addStyleName(ValoTheme.BUTTON_SMALL);
        AddButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);

        DeleteButton = new Button();
        DeleteButton.setIcon(VaadinIcons.CLOSE_CIRCLE);
        DeleteButton.addStyleName(ValoTheme.BUTTON_SMALL);
        DeleteButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);
        DeleteButton.setData(this);


        HorizontalLayout HeaderButtons = new HorizontalLayout(
                DeleteButton
                ,AddButton
                ,SaveButton
        );
        HeaderButtons.setSpacing(true);
        HeaderButtons.setSizeUndefined();

        HorizontalLayout HeaderLayout = new HorizontalLayout(
                Header
                ,HeaderButtons
        );
        HeaderLayout.setWidth("100%");
        HeaderLayout.setHeightUndefined();
        HeaderLayout.setComponentAlignment(Header, Alignment.MIDDLE_LEFT);
        HeaderLayout.setComponentAlignment(HeaderButtons,Alignment.MIDDLE_RIGHT);

        iNotificationTable = new Table();
        iNotificationTable.setWidth("100%");

        iNotificationTable.setColumnHeader(1, "№<br/>оповещения");
        iNotificationTable.setColumnHeader(2, "Условие<br/>оповещения");
        iNotificationTable.setColumnHeader(3, "Критерий<br/>оповещения");
        iNotificationTable.setColumnHeader(4, "Интервал<br/>срабатывания, с");

        iNotificationContainer = new IndexedContainer();
        iNotificationContainer.addContainerProperty(1, Integer.class, null);
        iNotificationContainer.addContainerProperty(2, TextField.class, null);
        iNotificationContainer.addContainerProperty(3, HorizontalLayout.class, null);
        iNotificationContainer.addContainerProperty(4, Integer.class, null);

        setNotificationContainer();

        iNotificationTable.setContainerDataSource(iNotificationContainer);


        iNotificationTable.setPageLength(iNotificationContainer.size());



        iNotificationTable.addStyleName(ValoTheme.TABLE_COMPACT);
        iNotificationTable.addStyleName(ValoTheme.TABLE_SMALL);
        iNotificationTable.addStyleName("TableRow");


        iNotificationTable.setSelectable(true);

        VerticalLayout NotificationTableLayout = new VerticalLayout(
                iNotificationTable
        );
        NotificationTableLayout.setWidth("100%");
        NotificationTableLayout.setHeightUndefined();
        NotificationTableLayout.setComponentAlignment(iNotificationTable,Alignment.MIDDLE_CENTER);

        VerticalLayout ContentLayout = new VerticalLayout(
                HeaderLayout
                ,NotificationTableLayout
        );
        ContentLayout.setSpacing(true);
        ContentLayout.setWidth("100%");
        ContentLayout.setHeightUndefined();

        this.addComponent(ContentLayout);

    }

    public void setNotificationContainer(){

    }

}
