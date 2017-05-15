package com.vaadin;

import com.vaadin.data.Item;
import com.vaadin.icons.VaadinIcons;
import com.vaadin.server.FontAwesome;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

import java.util.List;

/**
 * Created by kalistrat on 15.05.2017.
 */
public class tFolderDeleteWindow extends Window {

    Button DeleteButton;
    Button CancelButton;
    Label WarningLabel;
    tTreeContentLayout iTreeContentLayout;
    int iLeafId;
    int iNewTreeId;
    int iNewLeafId;

    public tFolderDeleteWindow(int eLeafId
            ,tTreeContentLayout eParentContentLayout
    ){
        iLeafId = eLeafId;
        iTreeContentLayout = eParentContentLayout;

        iNewTreeId = 0;
        iNewLeafId = 0;


        this.setIcon(VaadinIcons.FOLDER_REMOVE);
        this.setCaption(" Добавление подкаталога");

        WarningLabel = new Label();


        DeleteButton = new Button("Удалить");

        DeleteButton.setData(this);
        DeleteButton.addStyleName(ValoTheme.BUTTON_SMALL);
        DeleteButton.setIcon(VaadinIcons.FOLDER_REMOVE);

        DeleteButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {


                    //addSubFolder(iLeafId,sFieldValue,iTreeContentLayout.iUserLog);

                for (Integer iLf : iTreeContentLayout.GetChildLeafsById(iLeafId)) {
                    iTreeContentLayout.itTree.TreeContainer.removeItem(iLf);
                }

                iTreeContentLayout.itTree.TreeContainer.removeItem(iLeafId);
                Integer ParentLeafId = iTreeContentLayout.GetParentLeafById(iLeafId);

                iTreeContentLayout.itTree.select(ParentLeafId);

                iTreeContentLayout.tTreeContentLayoutRefresh(ParentLeafId,0);

                Notification.show("Подкаталог удалён!",
                        null,
                        Notification.Type.TRAY_NOTIFICATION);
                UI.getCurrent().removeWindow((tAddFolderWindow) clickEvent.getButton().getData());

            }
        });

        HorizontalLayout ButtonsLayout = new HorizontalLayout(
                DeleteButton
        );

        ButtonsLayout.setSizeUndefined();
        ButtonsLayout.setSpacing(true);

        VerticalLayout MessageLayout = new VerticalLayout(
                WarningLabel
        );
        MessageLayout.setSpacing(true);
        MessageLayout.setWidth("320px");
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
