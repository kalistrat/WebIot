package com.vaadin;

import com.vaadin.icons.VaadinIcons;
import com.vaadin.server.FontAwesome;
import com.vaadin.shared.ui.label.ContentMode;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

import java.util.List;

/**
 * Created by kalistrat on 19.05.2017.
 */
public class tDeviceDeleteWindow extends Window {
    Button DeleteButton;
    Button CancelButton;
    Label WarningLabel;
    tTreeContentLayout iTreeContentLayout;
    int iLeafId;


    public tDeviceDeleteWindow(int eLeafId
            ,tTreeContentLayout eParentContentLayout
    ){
        iLeafId = eLeafId;
        iTreeContentLayout = eParentContentLayout;

        this.setIcon(VaadinIcons.CLOSE_CIRCLE);
        this.setCaption(" Удаление устройства");

        WarningLabel = new Label();

        WarningLabel = new Label(
                "ВНИМАНИЕ! Данное устройство будет удалено.\n"
                + "Вы не сможете востановить информацию\n"
                + "об измерениях и переходах"
        );
        WarningLabel.setContentMode(ContentMode.PREFORMATTED);
        WarningLabel.addStyleName("WarningFont");


        DeleteButton = new Button("Удалить");
        DeleteButton.setData(this);
        DeleteButton.addStyleName(ValoTheme.BUTTON_SMALL);
        DeleteButton.setIcon(VaadinIcons.CLOSE_CIRCLE);

        DeleteButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {

                String sParentLeafName = iTreeContentLayout
                        .GetLeafNameById(iTreeContentLayout.GetParentLeafById(iLeafId));


                tUsefulFuctions.updateDeviceMqttLogger(
                        iTreeContentLayout.getLeafUserDeviceId(iLeafId)
                        ,iTreeContentLayout.iUserLog
                        ,"delete"
                );

                tUsefulFuctions.deleteUserDevice(iTreeContentLayout.iUserLog,iLeafId);

                iTreeContentLayout.reloadTreeContainer();
                Integer iNewParentLeafId = iTreeContentLayout.getLeafIdByName(sParentLeafName);

                for (Object id : iTreeContentLayout.itTree.rootItemIds()) {
                    iTreeContentLayout.itTree.expandItemsRecursively(id);
                }

                iTreeContentLayout.tTreeContentLayoutRefresh(iNewParentLeafId,0);

                Notification.show("Устройство удалёно!",
                                    null,
                                    Notification.Type.TRAY_NOTIFICATION);
                UI.getCurrent().removeWindow((tDeviceDeleteWindow) clickEvent.getButton().getData());

            }
        });

        CancelButton = new Button("Отменить");
        CancelButton.setData(this);
        CancelButton.addStyleName(ValoTheme.BUTTON_SMALL);
        CancelButton.setIcon(FontAwesome.HAND_STOP_O);

        CancelButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                UI.getCurrent().removeWindow((tDeviceDeleteWindow) clickEvent.getButton().getData());
            }
        });

        HorizontalLayout ButtonsLayout = new HorizontalLayout(
                DeleteButton
                ,CancelButton
        );

        ButtonsLayout.setSizeUndefined();
        ButtonsLayout.setSpacing(true);

        VerticalLayout MessageLayout = new VerticalLayout(
                WarningLabel
        );
        MessageLayout.setSpacing(true);
        MessageLayout.setWidth("400px");
        MessageLayout.setHeightUndefined();
        MessageLayout.setMargin(true);
        MessageLayout.setComponentAlignment(WarningLabel, Alignment.MIDDLE_CENTER);
        MessageLayout.addStyleName(ValoTheme.LAYOUT_WELL);

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
}
