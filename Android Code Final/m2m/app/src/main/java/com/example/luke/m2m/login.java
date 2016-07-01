package com.example.luke.m2m;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;

import m2m.app.api.weavedapi;

public class login extends ActionBarActivity {
    SharedPreference sharedpreference;
    Activity context = this;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        sharedpreference = new SharedPreference();
    }

    public void loginClick(View view) {
        EditText lEdit   = (EditText)findViewById(R.id.input_email);
        String login = lEdit.getText().toString();
        EditText pEdit   = (EditText)findViewById(R.id.input_password);
        String pass = pEdit.getText().toString();


        sharedpreference.save(context, login, 0);
        sharedpreference.save(context, pass,  1);



        writeToFile(login, "logininfo");
        writeToFile(pass, "logincredentials");
        weavedapi WeavedAPI = new weavedapi();
        if(WeavedAPI.login(readFromFile("logininfo"), readFromFile("logincredentials"))){
            Context context = getApplicationContext();
            CharSequence text = "Login Successful";
            int duration = Toast.LENGTH_SHORT;
            Toast toast = Toast.makeText(context, text, duration);
            toast.show();
            //if successful take them out of login page
            Intent intent = new Intent(this, piLogin.class);
           startActivity(intent);
        }else{
            Context context = getApplicationContext();
            CharSequence text = "Login Failed. Please Try again";
            int duration = Toast.LENGTH_SHORT;

            Toast toast = Toast.makeText(context, text, duration);
            toast.show();

        }

    }

    private void writeToFile(String data, String fname) {
        try {
            OutputStreamWriter outputStreamWriter = new OutputStreamWriter(getApplicationContext().openFileOutput(fname +".txt", Context.MODE_WORLD_WRITEABLE));
            outputStreamWriter.write(data);
            outputStreamWriter.close();
        }
        catch (IOException e) {
            Log.e("Exception", "File write failed: " + e.toString());
        }
    }
    private String readFromFile(String fname) {

        String ret = "";

        try {
            InputStream inputStream = openFileInput(fname + ".txt");

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

}
