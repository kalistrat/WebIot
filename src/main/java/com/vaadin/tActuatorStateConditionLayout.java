package com.vaadin;

import com.vaadin.data.Item;
import com.vaadin.data.util.HierarchicalContainer;
import com.vaadin.data.util.IndexedContainer;
import com.vaadin.icons.VaadinIcons;
import com.vaadin.server.FontAwesome;
import com.vaadin.shared.ui.label.ContentMode;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

/**
 * Created by kalistrat on 26.05.2017.
 */
public class tActuatorStateConditionLayout extends VerticalLayout {

    Button AddButton;
    Button DeleteButton;
    Button SaveButton;

    TreeTable StatesConditionTable;
    HierarchicalContainer StatesConditionContainer;
    int iUserDeviceId;


    public tActuatorStateConditionLayout(int eUserDeviceId){

        iUserDeviceId = eUserDeviceId;

        Label Header = new Label();
        Header.setContentMode(ContentMode.HTML);
        Header.setValue(VaadinIcons.TREE_TABLE.getHtml() + "  " + "Условия, реализующие состояния устройства");
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

        StatesConditionTable = new TreeTable();

        StatesConditionTable.setColumnHeader(1, "Наименование<br/>состояния");
        StatesConditionTable.setColumnHeader(2, "Левая часть<br/>выражения");
        StatesConditionTable.setColumnHeader(3, "Знак");
        StatesConditionTable.setColumnHeader(4, "Правая часть<br/>выражения");

        StatesConditionContainer = new HierarchicalContainer();
        StatesConditionContainer.addContainerProperty(1, String.class, null);
        StatesConditionContainer.addContainerProperty(2, String.class, null);
        StatesConditionContainer.addContainerProperty(3, String.class, null);
        StatesConditionContainer.addContainerProperty(4, String.class, null);

        //setStatesContainer();

        Item AddedItem1 = StatesConditionContainer.addItem(1);
        AddedItem1.getItemProperty(1).setValue("Включено");
        AddedItem1.getItemProperty(2).setValue(null);
        AddedItem1.getItemProperty(3).setValue(null);
        AddedItem1.getItemProperty(4).setValue(null);

        Item AddedItem2 = StatesConditionContainer.addItem(2);
        AddedItem2.getItemProperty(1).setValue("Условие включения");
        AddedItem2.getItemProperty(2).setValue("a+b");
        AddedItem2.getItemProperty(3).setValue(">");
        AddedItem2.getItemProperty(4).setValue("c");

        StatesConditionContainer.setParent(2,1);


        StatesConditionTable.setContainerDataSource(StatesConditionContainer);

        // Expand the tree
        for (Object itemId: StatesConditionTable.getContainerDataSource()
                .getItemIds()) {
            StatesConditionTable.setCollapsed(itemId, false);

            // Also disallow expanding leaves
            if (! StatesConditionTable.hasChildren(itemId))
                StatesConditionTable.setChildrenAllowed(itemId, false);
        }

        if (StatesConditionContainer.size()<6) {
            StatesConditionTable.setPageLength(StatesConditionContainer.size());
        } else {
            StatesConditionTable.setPageLength(6);
        }
        StatesConditionTable.addStyleName(ValoTheme.TREETABLE_SMALL);
        StatesConditionTable.addStyleName(ValoTheme.TREETABLE_COMPACT);
        StatesConditionTable.addStyleName("TableRow");


        StatesConditionTable.setSelectable(true);


        VerticalLayout TableLayout = new VerticalLayout(
                StatesConditionTable
        );
        TableLayout.setWidth("100%");
        TableLayout.setHeightUndefined();
        TableLayout.setComponentAlignment(StatesConditionTable,Alignment.MIDDLE_CENTER);
        //StatesTableLayout.addStyleName(ValoTheme.LAYOUT_WELL);

        VerticalLayout ContentLayout = new VerticalLayout(
                HeaderLayout
                ,TableLayout
        );
        ContentLayout.setSpacing(true);
        ContentLayout.setWidth("100%");
        ContentLayout.setHeightUndefined();

        this.addComponent(ContentLayout);

    }
}
