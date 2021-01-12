package com.example.testandroidapp;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        System.out.println(add_number(5,3));

    }
    private Integer add_number(Integer a, Integer b){
        return a+b;

    }
    public void b_add(View view){

        String a = ((EditText)findViewById(R.id.txtNumberA)).getText().toString();
        String b = ((EditText)findViewById(R.id.txtNumberB)).getText().toString();

        TextView t = new TextView(this);

        t = (TextView)findViewById(R.id.lblResult);

        t.setText(a+b);

    }

}
