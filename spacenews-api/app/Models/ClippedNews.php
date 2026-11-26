<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ClippedNews extends Model
{
    protected $fillable = ['user_id', 'mission_id', 'title', 'news_site', 'image_url', 'notes'];
    public function mission() {
        return $this->belongsTo(Mission::class);
    }
}
