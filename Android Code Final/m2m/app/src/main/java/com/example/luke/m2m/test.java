package com.example.luke.m2m;

import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.widget.TextView;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import m2m.app.api.weavedapi;

public class test extends ActionBarActivity {
    private TextView myText = null;
    TextView data;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dev);
        data = (TextView) findViewById(R.id.textView);

        setText(parseJSON(readFromFile()));
    }

    //Set text method
    protected void setText(String s) {
        data = (TextView) findViewById(R.id.textView);
        data.setText(s);
    }

    //Set's Toast Message
    protected void setToast(String s) {
        Toast toast = Toast.makeText(getApplicationContext(), s, Toast.LENGTH_LONG);
        toast.show();
    }


    private void writeToFile(String data) {
        try {
            OutputStreamWriter outputStreamWriter = new OutputStreamWriter(getApplicationContext().openFileOutput("pijson.txt", Context.MODE_PRIVATE));
            outputStreamWriter.write(data);
            outputStreamWriter.close();
        }
        catch (IOException e) {
            Log.e("Exception", "File write failed: " + e.toString());
        }
    }
    private String readFromFile() {

        String ret = "";

        try {
            InputStream inputStream = openFileInput("pijson.txt");

            if ( inputStream != null ) {
                InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
                String receiveString = "";
                StringBuilder stringBuilder = new StringBuilder();

                while ( (receiveString = bufferedReader.readLine()) != null ) {
                    stringBuilder.append(receiveString);
                }

                inputStream.close();
                ret = stringBuilder.toString();
            }
        }
        catch (FileNotFoundException e) {
            Log.e("login activity", "File not found: " + e.toString());
        } catch (IOException e) {
            Log.e("login activity", "Can not read file: " + e.toString());
        }

        return ret;
    }
    private String parseJSON(String s){
        String[] eh = readFromFile().split("number");
        String temp = "";
        for(int x = 1; x< eh.length; x++)
        {
            Matcher matcher = Pattern.compile("\\d+").matcher(eh[x]);
            matcher.find();
            temp +="Pin " + matcher.group() + ":\n";
            if(eh[x].contains("state\":\"true\"")){
                temp+= "state: true \n\n";
            }else {
                temp+= "state: false\n\n";
            }
            //  temp+=element.parseInt() +"\n \n";
        }
        return temp;
    }
}