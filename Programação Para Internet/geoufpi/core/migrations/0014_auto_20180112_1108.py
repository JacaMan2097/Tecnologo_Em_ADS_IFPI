# -*- coding: utf-8 -*-
# Generated by Django 1.11 on 2018-01-12 13:08
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0013_auto_20180112_1108'),
    ]

    operations = [
        migrations.AlterField(
            model_name='tutor',
            name='curso',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, related_name='cursos', to='core.Curso', verbose_name='Curso'),
        ),
    ]
