# -*- coding: utf-8 -*-
# Generated by Django 1.11 on 2018-01-09 17:44
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0007_relatorio_image'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='relatorio',
            name='image',
        ),
        migrations.AddField(
            model_name='tutor',
            name='image',
            field=models.ImageField(blank=True, upload_to='core/static/images', verbose_name='Imagem'),
        ),
    ]
