# -*- coding: utf-8 -*-
# Generated by Django 1.11 on 2018-01-11 12:44
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0008_auto_20180109_1544'),
    ]

    operations = [
        migrations.CreateModel(
            name='Curso',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('nome', models.CharField(max_length=45, verbose_name='Nome do Curso')),
                ('image', models.ImageField(blank=True, upload_to='core/static/images', verbose_name='Imagem')),
            ],
            options={
                'verbose_name': 'Curso',
                'verbose_name_plural': 'Cursos',
            },
        ),
    ]
