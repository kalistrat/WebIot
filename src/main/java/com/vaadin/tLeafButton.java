package com.vaadin;

import com.vaadin.icons.VaadinIcons;
import com.vaadin.server.FontAwesome;
import com.vaadin.ui.Button;
import com.vaadin.ui.NativeButton;
import com.vaadin.ui.themes.ValoTheme;

import java.sql.*;

/**
 * Created by kalistrat on 13.01.2017.
 */
public class tLeafButton extends Button {

    public tLeafButton(int eButtonLeafId,tTreeContentLayout iParentContentLayout){

        String iButtonCaption = (String) iParentContentLayout.itTree.getItem(eButtonLeafId).getItemProperty(4).getValue();
        String iButtonIconCode = (String) iParentContentLayout.itTree.getItem(eButtonLeafId).getItemProperty(5).getValue();
        Integer iUserDeviceId = (Integer) iParentContentLayout.itTree.getItem(eButtonLeafId).getItemProperty(6).getValue();

        iButtonCaption = iButtonCaption.replace(" ","\n");
        System.out.println(iButtonCaption);

        this.setCaption(iButtonCaption);

        if (iButtonIconCode.equals("FOLDER")) {
            this.setIcon(FontAwesome.FOLDER);
        }
        if (iButtonIconCode.equals("TACHOMETER")) {
            this.setIcon(FontAwesome.TACHOMETER);
        }
        if (iButtonIconCode.equals("AUTOMATION")) {
            this.setIcon(VaadinIcons.AUTOMATION);
        }

        this.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                iParentContentLayout.tTreeContentLayoutRefresh(eButtonLeafId,iUserDeviceId);
            }
        });


        this.setSizeUndefined();
        this.addStyleName("ButtonHugeIcon");
        this.addStyleName(ValoTheme.BUTTON_ICON_ALIGN_TOP);
        this.addStyleName(ValoTheme.BUTTON_LINK);


    }

}
