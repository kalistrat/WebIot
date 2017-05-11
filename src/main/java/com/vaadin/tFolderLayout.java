package com.vaadin;

import com.vaadin.data.Item;
import com.vaadin.data.util.IndexedContainer;
import com.vaadin.server.FontAwesome;
import com.vaadin.server.Sizeable;
import com.vaadin.shared.ui.MarginInfo;
import com.vaadin.shared.ui.label.ContentMode;
import com.vaadin.ui.*;
import com.vaadin.ui.themes.ValoTheme;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by kalistrat on 13.01.2017.
 */
public class tFolderLayout extends VerticalLayout {

    List<Integer> ChildLeafs = new ArrayList<Integer>();
    List<HorizontalLayout> ChildLeafsRows = new ArrayList<HorizontalLayout>();
    Table tFolderTable;
    IndexedContainer tFolderContainer;
    Button tReturnParentFolderButton;
    tTreeContentLayout tParentContentLayout;
    Integer tCurrentLeafId;

    //int tLeafId;
    //tTreeContentLayout tParentContentLayout;

    public  tFolderLayout(int LeafId, tTreeContentLayout ParentContentLayout){

        VerticalLayout FolderContentLayout = new VerticalLayout();
        this.tParentContentLayout = ParentContentLayout;
        this.tCurrentLeafId = LeafId;

        //tLeafId = LeafId;
        //tParentContentLayout = ParentContentLayout;

        int ncol = 0;
        int nrow = 0;
//        HorizontalLayout FirstChildLeafRow = new HorizontalLayout();
//        FirstChildLeafRow.setMargin(true);
//        FirstChildLeafRow.setSpacing(true);
//        //FirstChildLeafRow.setSizeFull();
//        this.ChildLeafsRows.add(FirstChildLeafRow);
//        this.ChildLeafs = ParentContentLayout.GetChildLeafsById(LeafId);
//
//        for (Integer Chids : this.ChildLeafs) {
//            this.ChildLeafsRows.get(nrow).addComponent(new tLeafButton(Chids, ParentContentLayout));
//            ncol = ncol + 1;
//            if (ncol > 2) {
//                HorizontalLayout ChildLeafRow = new HorizontalLayout();
//                //ChildLeafRow.setSizeFull();
//                ChildLeafRow.setMargin(true);
//                ChildLeafRow.setSpacing(true);
//                this.ChildLeafsRows.add(ChildLeafRow);
//                ncol = 0;
//                nrow = nrow + 1;
//            }
//        }
//
//        for (HorizontalLayout LeafsRows : this.ChildLeafsRows) {
//            FolderContentLayout.addComponent(LeafsRows);
//
//            FolderContentLayout.setComponentAlignment(LeafsRows, Alignment.MIDDLE_CENTER);
//        }

        tFolderTable = new Table();
        //tFolderTable.setColumnHeaderMode(Table.ColumnHeaderMode.HIDDEN);
        tFolderContainer = new IndexedContainer();
//        tFolderContainer.addContainerProperty(1, tLeafButtonLayout.class, null);
//        tFolderContainer.addContainerProperty(2, tLeafButtonLayout.class, null);
//        tFolderContainer.addContainerProperty(3, tLeafButtonLayout.class, null);

        tFolderContainer.addContainerProperty(1, tTableNodeLayout.class, null);
        tFolderContainer.addContainerProperty(2, tTableNodeLayout.class, null);
        tFolderContainer.addContainerProperty(3, tTableNodeLayout.class, null);

        this.ChildLeafs = ParentContentLayout.GetChildLeafsById(LeafId);

        if (this.ChildLeafs.size() != 0) {
            int ChS = this.ChildLeafs.size();
            Double CntItems = Math.ceil(ChS/(double) 3);
            int CntItemsI = CntItems.intValue();
            System.out.println("this.ChildLeafs.size() " + this.ChildLeafs.size());
            System.out.println("CntItemsI " + CntItemsI);

            for (int i = 0; i< Math.ceil(this.ChildLeafs.size()/(double) 3); i++){
                this.tFolderContainer.addItem();
                for (int j = 0; j < 3; j++) {
                    this.tFolderContainer.getItem(this.tFolderContainer.getIdByIndex(this.tFolderContainer.size() - 1))
                            .getItemProperty(j+1).setValue(new tTableNodeLayout());
                }
            }

            for (Integer Chids : this.ChildLeafs) {
                ncol = ncol + 1;
                tTableNodeLayout tTableNodeLayoutNode = (tTableNodeLayout) this.tFolderContainer.getItem(this.tFolderContainer.getIdByIndex(nrow))
                        .getItemProperty(ncol).getValue();
                tLeafButtonLayout tLeafButtonNodeLayout = new tLeafButtonLayout(Chids, ParentContentLayout);
                tTableNodeLayoutNode.addComponent(tLeafButtonNodeLayout);
                tTableNodeLayoutNode.setComponentAlignment(tLeafButtonNodeLayout,Alignment.MIDDLE_CENTER);
                if (ncol > 2) {
                    ncol = 0;
                    nrow = nrow + 1;
                }

            }

//            this.tFolderContainer.addItem();
//
//            for (Integer Chids : this.ChildLeafs) {
//                ncol = ncol + 1;
//                this.tFolderContainer.getItem(this.tFolderContainer.getIdByIndex(this.tFolderContainer.size() - 1))
//                        .getItemProperty(ncol).setValue(new tLeafButtonLayout(Chids, ParentContentLayout));
//                if (ncol > 2) {
//                    this.tFolderContainer.addItem();
//                    ncol = 0;
//
//                }
//
//            }

            this.tFolderTable.setContainerDataSource(this.tFolderContainer);
            this.tFolderTable.setPageLength(this.tFolderContainer.size());
            this.tFolderTable.addStyleName(ValoTheme.TABLE_NO_HEADER);
            //this.tFolderTable.addStyleName(ValoTheme.TABLE_NO_VERTICAL_LINES);
            //this.tFolderTable.addStyleName(ValoTheme.TABLE_NO_HORIZONTAL_LINES);
            this.tFolderTable.addStyleName(ValoTheme.TABLE_NO_STRIPES);
            this.tFolderTable.setColumnAlignment(1,Table.Align.CENTER);
            this.tFolderTable.setColumnAlignment(2,Table.Align.CENTER);
            this.tFolderTable.setColumnAlignment(3,Table.Align.CENTER);


            FolderContentLayout.addComponent(this.tFolderTable);
            FolderContentLayout.setComponentAlignment(this.tFolderTable,Alignment.TOP_CENTER);

        }


        Label TopLabel = new Label();
        TopLabel.setContentMode(ContentMode.HTML);

        TopLabel.setValue(FontAwesome.FOLDER.getHtml() + " " + ParentContentLayout.GetLeafNameById(LeafId));
        TopLabel.addStyleName(ValoTheme.LABEL_COLORED);
        TopLabel.addStyleName(ValoTheme.LABEL_SMALL);

        tReturnParentFolderButton = new Button("Вверх");
        tReturnParentFolderButton.setIcon(FontAwesome.LEVEL_UP);
        tReturnParentFolderButton.addStyleName(ValoTheme.BUTTON_SMALL);
        //tReturnParentFolderButton.addStyleName(ValoTheme.BUTTON_ICON_ONLY);
        tReturnParentFolderButton.addStyleName(ValoTheme.BUTTON_BORDERLESS_COLORED);

        tReturnParentFolderButton.addClickListener(new Button.ClickListener() {
            @Override
            public void buttonClick(Button.ClickEvent clickEvent) {
                Integer iParentLeafId = tParentContentLayout.GetParentLeafById(tCurrentLeafId);
                //System.out.println("tCurrentLeafId: " + tCurrentLeafId);
                //System.out.println("iParentLeafId: " + iParentLeafId);
                if (iParentLeafId != 0){
                    tParentContentLayout.tTreeContentLayoutRefresh(iParentLeafId,0);
                }
            }
        });

        HorizontalLayout TopLabelLayout = new HorizontalLayout(TopLabel,tReturnParentFolderButton);
        TopLabelLayout.setComponentAlignment(TopLabel,Alignment.MIDDLE_LEFT);
        TopLabelLayout.setComponentAlignment(tReturnParentFolderButton,Alignment.MIDDLE_RIGHT);

        TopLabelLayout.setSizeFull();
        FolderContentLayout.setSizeFull();
        TopLabelLayout.setMargin(new MarginInfo(false, true, false, true));
        FolderContentLayout.setMargin(true);

        VerticalSplitPanel SplPanel = new VerticalSplitPanel();
        SplPanel.setFirstComponent(TopLabelLayout);
        SplPanel.setSecondComponent(FolderContentLayout);
        SplPanel.setSplitPosition(40, Sizeable.UNITS_PIXELS);
        SplPanel.setHeight("500px");
        //SplPanel.setWidth("1000px");

        this.addComponent(SplPanel);
        this.setSpacing(true);
        this.setSizeFull();

        //this.setSizeFull();

    }

}
