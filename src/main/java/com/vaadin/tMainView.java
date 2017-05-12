package com.vaadin;


import com.vaadin.navigator.View;
import com.vaadin.navigator.ViewChangeListener;
import com.vaadin.server.FontAwesome;
import com.vaadin.server.Sizeable;
import com.vaadin.server.ThemeResource;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

/**
 * Created by SemenovNA on 03.08.2016.
 */
public class tMainView extends CustomComponent implements View {

    public static final String NAME = "";

    String CurrentUsr;
    tTreeContentLayout TreeContentUsr;

    Button LogOutButton = new Button("Выйти", new Button.ClickListener() {
        @Override
        public void buttonClick(Button.ClickEvent event) {
            // "Logout" the user
            getSession().setAttribute("user", null);
            // Refresh this view, should redirect to login view
            getUI().getNavigator().navigateTo(NAME);
        }
    });


    private TabSheet t;

    public tMainView(){

    }

    public void enter(ViewChangeListener.ViewChangeEvent event) {

        this.CurrentUsr = (String) getSession().getAttribute("user");


        //setSizeFull();

        VerticalLayout tMainViewContent = new VerticalLayout();
        LogOutButton.setStyleName(ValoTheme.BUTTON_LINK);
        LogOutButton.setIcon(FontAwesome.SIGN_OUT);
        HorizontalLayout TopSec = new HorizontalLayout(LogOutButton);
        TopSec.setComponentAlignment(LogOutButton,Alignment.TOP_RIGHT);
        TopSec.setHeight("70px");
        TopSec.setWidth("100%");
        //TopSec.addStyleName(ValoTheme.LAYOUT_CARD);
        tMainViewContent.setSizeFull();

        HorizontalSplitPanel MidSec = new HorizontalSplitPanel();

//        VerticalLayout DeviceForm = new VerticalLayout();
//        DeviceForm.setMargin(true);
//        DeviceForm.addComponent(new tDeviceLayout());

        tTree DeviceTree = new tTree(this.CurrentUsr,this);
        DeviceTree.addStyleName("CaptionTree");

        DeviceTree.setSizeFull();
        //DeviceForm.addStyleName(ValoTheme.LAYOUT_CARD);
        //DeviceTree.addStyleName(ValoTheme.LAYOUT_CARD);

        MidSec.addComponent(DeviceTree);

        this.TreeContentUsr = new tTreeContentLayout(CurrentUsr,DeviceTree);
        MidSec.addComponent(this.TreeContentUsr);

        //MidSec.setHeight("1000px");
        //MidSec.setWidth("1000px");
        MidSec.setSizeFull();
        MidSec.setSplitPosition(35, Sizeable.UNITS_PERCENTAGE); // percent
        //MidSec.addStyleName(ValoTheme.LAYOUT_CARD);


        tMainViewContent.addComponent(TopSec);


        VerticalLayout Tab1Cont = new VerticalLayout();
        Tab1Cont.setMargin(true);
        Tab1Cont.addComponent(MidSec);
        // Tab 2 content
        Label Tab2Cont = new Label("Здесь будет что-то");
        //Tab2Cont.setMargin(true);
        //Tab2Cont.addComponent(new Label("Здесь будет настройка"));
        // Tab 3 content
        VerticalLayout Tab3Cont = new VerticalLayout();
        Tab3Cont.setMargin(true);
        Tab3Cont.addComponent(new Label("Здесь будет архив,а может что-то другое"));

        t = new TabSheet();
        //t.setHeight("200px");
        //t.setWidth("400px");

        t.addTab(Tab1Cont, "Показания датчиков",FontAwesome.TASKS);
        t.addTab(Tab2Cont, "Настройка датчиков", FontAwesome.GEARS);
        t.addTab(Tab3Cont, "Архив показаний", FontAwesome.ARCHIVE);
        //t.addListener(this);
        t.setSizeFull();

        tMainViewContent.addComponent(t);

        setCompositionRoot(tMainViewContent);
    }
}
