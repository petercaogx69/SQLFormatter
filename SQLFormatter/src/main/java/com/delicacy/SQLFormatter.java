package com.delicacy;

import com.intellij.openapi.actionSystem.AnAction;
import com.intellij.openapi.actionSystem.AnActionEvent;
import com.intellij.openapi.actionSystem.CommonDataKeys;
import com.intellij.openapi.command.WriteCommandAction;
import com.intellij.openapi.editor.Document;
import com.intellij.openapi.editor.Editor;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.ui.Messages;
import delicacy.client.BaseCollection;
import delicacy.client.DelicacyClient;
import delicacy.client.SQLFormatterResult;
import org.jetbrains.annotations.NotNull;

import java.net.URLDecoder;


public class SQLFormatter extends AnAction implements Runnable {

    private Project currentProject = null;
    private Document documentDocument = null;
    private CharSequence result = null;
    private BaseCollection<SQLFormatterResult> formatResult;

    @Override
    public void actionPerformed(@NotNull AnActionEvent e) {

        try {
            Editor editor = e.getRequiredData(CommonDataKeys.EDITOR);
            currentProject = editor.getProject();
            Document doc = editor.getDocument();
            documentDocument = doc;
            String txt = doc.getText();
            formatResult = DelicacyClient.callFormatter("www.spdycoding.com",7137,txt);
            if(formatResult.getStatus() == 0){
                result = URLDecoder.decode(formatResult.getUserData().toString(), "UTF-8");
                WriteCommandAction.runWriteCommandAction(this.currentProject, this);
            }else{
                Messages.showInputDialog(formatResult.getMessage(), "Please input your active code here...", null);
//                Messages.showDialog(formatResult.getMessage(), "Info", null, 0, null);
            }

        }catch(Exception ee) {
            ee.printStackTrace();
        }


    }

    @Override
    public void run() {
        documentDocument.deleteString(0, documentDocument.getTextLength());
        documentDocument.insertString(0, result);
    }
}
